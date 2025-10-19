#!/usr/bin/env python3
"""
FlowTech-AI Notes Sync - Obsidian → Qdrant RAG
Synchronisation intelligente des notes Markdown avec détection de changements
"""

import hashlib
import json
import os
import re
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple
import yaml

try:
    from qdrant_client import QdrantClient
    from qdrant_client.models import PointStruct, Distance, VectorParams
    from fastembed import TextEmbedding
except ImportError:
    print("❌ Erreur: Dépendances manquantes")
    print("   Installer: pip install qdrant-client fastembed pyyaml")
    sys.exit(1)


# ========================================
# CONFIGURATION
# ========================================

class Config:
    """Configuration du service de synchronisation"""
    
    # Qdrant
    QDRANT_URL = os.getenv("QDRANT_URL", "http://localhost:6333")
    COLLECTION_NAME = os.getenv("NOTES_COLLECTION", "cursor-knowledge")
    
    # Embedding
    EMBEDDING_MODEL = os.getenv("EMBEDDING_MODEL", "BAAI/bge-large-en-v1.5")
    VECTOR_SIZE = 1024  # BAAI/bge-large-en-v1.5
    
    # Paths (can be mounted as Docker volume)
    NOTES_PATH = Path(os.getenv("NOTES_PATH", "/notes"))
    CACHE_PATH = Path(os.getenv("CACHE_PATH", os.path.expanduser("~/.cache/flowtech-ai")))
    
    # Chunking
    MAX_CHUNK_SIZE = 512  # tokens
    CHUNK_OVERLAP = 0.2  # 20% overlap
    
    # Hash cache for change detection
    HASH_CACHE_FILE = CACHE_PATH / "notes_hashes.json"


# ========================================
# UTILITAIRES
# ========================================

def calculate_md5(file_path: Path) -> str:
    """Calcule le hash MD5 d'un fichier"""
    hasher = hashlib.md5()
    with open(file_path, 'rb') as f:
        hasher.update(f.read())
    return hasher.hexdigest()


def parse_frontmatter(content: str) -> Tuple[Optional[Dict], str]:
    """
    Parse le frontmatter YAML et retourne (metadata, contenu)
    """
    pattern = r'^---\s*\n(.*?)\n---\s*\n(.*)$'
    match = re.match(pattern, content, re.DOTALL)
    
    if not match:
        return None, content
    
    try:
        yaml_content = match.group(1)
        markdown_content = match.group(2)
        metadata = yaml.safe_load(yaml_content)
        return metadata, markdown_content
    except yaml.YAMLError as e:
        print(f"⚠️  Erreur parsing YAML: {e}")
        return None, content


def chunk_by_sections(content: str, metadata: Dict, file_path: str) -> List[Dict]:
    """
    Découpe le contenu par sections ## (titres niveau 2)
    Chaque chunk garde le contexte du titre parent
    """
    chunks = []
    
    # Split par sections ##
    sections = re.split(r'\n##\s+', content)
    
    # First element can be before the first ##
    if sections[0].strip():
        chunks.append({
            "text": sections[0].strip(),
            "section": metadata.get('title', 'Introduction'),
            "index": 0
        })
    
    # Sections suivantes
    for i, section in enumerate(sections[1:], 1):
        lines = section.split('\n', 1)
        section_title = lines[0].strip()
        section_content = lines[1].strip() if len(lines) > 1 else ""
        
        if section_content:
            chunk_text = f"## {section_title}\n\n{section_content}"
            chunks.append({
                "text": chunk_text,
                "section": section_title,
                "index": i
            })
    
    # Enrichir les chunks avec metadata
    enriched_chunks = []
    for chunk in chunks:
        enriched_chunks.append({
            "text": chunk["text"],
            "metadata": {
                "file_path": file_path,
                "section": chunk["section"],
                "chunk_index": chunk["index"],
                **metadata,  # Ajoute tout le frontmatter
                "synced_at": datetime.utcnow().isoformat()
            }
        })
    
    return enriched_chunks


def create_stable_id(file_path: str, chunk_index: int) -> str:
    """
    Crée un ID stable UUID pour un chunk basé sur le path + index
    Permet de remplacer les chunks lors des updates
    """
    import uuid
    content = f"{file_path}::{chunk_index}"
    # Create UUID v5 (deterministic based on namespace + name)
    namespace = uuid.UUID('6ba7b810-9dad-11d1-80b4-00c04fd430c8')  # DNS namespace
    return str(uuid.uuid5(namespace, content))


# ========================================
# GESTIONNAIRE QDRANT
# ========================================

class QdrantManager:
    """Gestion de la collection Qdrant"""
    
    def __init__(self):
        self.client = QdrantClient(url=Config.QDRANT_URL)
        self.embedding_model = None
        self.collection_name = Config.COLLECTION_NAME
        
    def init_collection(self):
        """Crée la collection si elle n'existe pas"""
        collections = self.client.get_collections().collections
        collection_names = [c.name for c in collections]
        
        if self.collection_name not in collection_names:
            print(f"📦 Création de la collection '{self.collection_name}'...")
            self.client.create_collection(
                collection_name=self.collection_name,
                vectors_config={
                    "": VectorParams(
                        size=Config.VECTOR_SIZE,
                        distance=Distance.COSINE
                    )
                }
            )
            print(f"✅ Collection créée")
        else:
            print(f"✅ Collection '{self.collection_name}' existe déjà")
    
    def load_embedding_model(self):
        """Charge le modèle d'embedding"""
        if self.embedding_model is None:
            print(f"🤖 Chargement du modèle {Config.EMBEDDING_MODEL}...")
            self.embedding_model = TextEmbedding(Config.EMBEDDING_MODEL)
            print("✅ Modèle chargé")
    
    def delete_file_chunks(self, file_path: str):
        """Supprime tous les chunks d'un fichier"""
        # Utilise scroll pour trouver tous les points du fichier
        scroll_result = self.client.scroll(
            collection_name=self.collection_name,
            scroll_filter={
                "must": [
                    {"key": "file_path", "match": {"value": file_path}}
                ]
            },
            limit=1000
        )
        
        point_ids = [point.id for point in scroll_result[0]]
        
        if point_ids:
            self.client.delete(
                collection_name=self.collection_name,
                points_selector=point_ids
            )
            print(f"  🗑️  Supprimé {len(point_ids)} anciens chunks")
        
        return len(point_ids)
    
    def upsert_chunks(self, chunks: List[Dict], file_path: str):
        """Insère les nouveaux chunks dans Qdrant"""
        if not chunks:
            return 0
        
        # Generate embeddings
        texts = [chunk["text"] for chunk in chunks]
        embeddings = list(self.embedding_model.embed(texts))
        
        # Create points
        points = []
        vector_name = ""  # Default vector
        
        for i, (chunk, embedding) in enumerate(zip(chunks, embeddings)):
            point_id = create_stable_id(file_path, chunk["metadata"]["chunk_index"])
            
            # Create complete payload with text AND metadata
            payload = {
                "text": chunk["text"],
                **chunk["metadata"]
            }
            
            points.append(PointStruct(
                id=point_id,
                vector={vector_name: embedding.tolist()},
                payload=payload
            ))
        
        # Upsert dans Qdrant
        self.client.upsert(
            collection_name=self.collection_name,
            points=points
        )
        
        print(f"  ✅ {len(points)} nouveaux chunks insérés")
        return len(points)


# ========================================
# SYNCHRONISATEUR
# ========================================

class NotesSynchronizer:
    """Synchronisation des notes Obsidian → Qdrant"""
    
    def __init__(self):
        self.qdrant = QdrantManager()
        self.hash_cache = self.load_hash_cache()
        self.stats = {
            "files_scanned": 0,
            "files_updated": 0,
            "files_skipped": 0,
            "chunks_created": 0,
            "chunks_deleted": 0,
            "errors": 0
        }
    
    def load_hash_cache(self) -> Dict[str, str]:
        """Charge le cache des hash MD5"""
        if Config.HASH_CACHE_FILE.exists():
            with open(Config.HASH_CACHE_FILE, 'r') as f:
                return json.load(f)
        return {}
    
    def save_hash_cache(self):
        """Sauvegarde le cache des hash"""
        Config.CACHE_PATH.mkdir(parents=True, exist_ok=True)
        with open(Config.HASH_CACHE_FILE, 'w') as f:
            json.dump(self.hash_cache, f, indent=2)
    
    def scan_notes(self) -> List[Path]:
        """Scanne tous les fichiers .md dans Notes/"""
        notes = []
        for md_file in Config.NOTES_PATH.rglob("*.md"):
            # Ignore special directories
            if any(part.startswith('_') or part.startswith('.') for part in md_file.parts):
                continue
            notes.append(md_file)
        
        return sorted(notes)
    
    def process_file(self, file_path: Path) -> bool:
        """
        Traite un fichier :
        1. Calcule hash
        2. Compare avec cache
        3. Si changement : parse, chunk, update Qdrant
        """
        try:
            # Path relatif pour ID stable
            rel_path = str(file_path.relative_to(Config.NOTES_PATH))
            
            # Calcul hash
            current_hash = calculate_md5(file_path)
            cached_hash = self.hash_cache.get(rel_path)
            
            # Pas de changement
            if current_hash == cached_hash:
                self.stats["files_skipped"] += 1
                return False
            
            print(f"\n📝 {rel_path}")
            
            # Lecture fichier
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Parse frontmatter
            metadata, markdown_content = parse_frontmatter(content)
            
            if not metadata:
                print(f"  ⚠️  Pas de frontmatter YAML, skip")
                return False
            
            # Chunking
            chunks = chunk_by_sections(markdown_content, metadata, rel_path)
            
            if not chunks:
                print(f"  ⚠️  Pas de contenu à indexer")
                return False
            
            print(f"  📄 {len(chunks)} chunks créés")
            
            # Suppression anciens chunks
            deleted = self.qdrant.delete_file_chunks(rel_path)
            self.stats["chunks_deleted"] += deleted
            
            # Insertion nouveaux chunks
            inserted = self.qdrant.upsert_chunks(chunks, rel_path)
            self.stats["chunks_created"] += inserted
            
            # Update cache
            self.hash_cache[rel_path] = current_hash
            self.stats["files_updated"] += 1
            
            return True
            
        except Exception as e:
            print(f"  ❌ Erreur: {e}")
            self.stats["errors"] += 1
            return False
    
    def sync(self):
        """Synchronisation complète"""
        print("=" * 80)
        print("🔄 FlowTech-AI Notes Sync - Obsidian → Qdrant RAG")
        print("=" * 80)
        
        # Init Qdrant
        print("\n📡 Connexion à Qdrant...")
        self.qdrant.init_collection()
        self.qdrant.load_embedding_model()
        
        # Scan notes
        print(f"\n📂 Scan du répertoire : {Config.NOTES_PATH}")
        notes = self.scan_notes()
        print(f"✅ {len(notes)} fichiers markdown trouvés")
        
        # Traitement
        print("\n🔄 Traitement des fichiers...")
        for note in notes:
            self.stats["files_scanned"] += 1
            self.process_file(note)
        
        # Sauvegarde cache
        self.save_hash_cache()
        
        # Rapport final
        print("\n" + "=" * 80)
        print("📊 RAPPORT FINAL")
        print("=" * 80)
        print(f"📁 Fichiers scannés    : {self.stats['files_scanned']}")
        print(f"✅ Fichiers mis à jour : {self.stats['files_updated']}")
        print(f"⏭️  Fichiers skippés    : {self.stats['files_skipped']}")
        print(f"📦 Chunks créés        : {self.stats['chunks_created']}")
        print(f"🗑️  Chunks supprimés    : {self.stats['chunks_deleted']}")
        print(f"❌ Erreurs             : {self.stats['errors']}")
        print("=" * 80)
        
        # Exit code
        return 0 if self.stats["errors"] == 0 else 1


# ========================================
# MAIN
# ========================================

def main():
    """Point d'entrée principal"""
    try:
        syncer = NotesSynchronizer()
        exit_code = syncer.sync()
        sys.exit(exit_code)
    except KeyboardInterrupt:
        print("\n⚠️  Interruption utilisateur")
        sys.exit(130)
    except Exception as e:
        print(f"\n❌ Erreur fatale: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()

