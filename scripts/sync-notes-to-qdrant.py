#!/usr/bin/env python3
"""
Sync Markdown notes from Notes/ folder to Qdrant collection 'cursor-knowledge'
Uses FastEmbed (BAAI/bge-large-en-v1.5) for embeddings
Implements hash-based caching to detect changes
"""

import os
import sys
import json
import hashlib
import uuid
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional, Tuple
import logging

# Third-party imports
try:
    from qdrant_client import QdrantClient
    from qdrant_client.models import PointStruct, Filter, FieldCondition, MatchValue
    from fastembed import TextEmbedding
    import yaml
except ImportError as e:
    print(f"❌ Missing dependency: {e}")
    print("Install with: pip install qdrant-client fastembed PyYAML")
    sys.exit(1)

# Configuration
QDRANT_URL = os.getenv("QDRANT_URL", "http://localhost:6333")
COLLECTION_NAME = os.getenv("COLLECTION_NAME", "cursor-knowledge")
EMBEDDING_MODEL = os.getenv("EMBEDDING_MODEL", "BAAI/bge-large-en-v1.5")
NOTES_PATH = os.getenv("NOTES_PATH", "./Notes")
CACHE_FILE = os.getenv("CACHE_FILE", "./AI_Data/notes-sync-cache.json")
CHUNK_SIZE = int(os.getenv("CHUNK_SIZE", "800"))
CHUNK_OVERLAP = int(os.getenv("CHUNK_OVERLAP", "100"))

# Logging setup
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class NotesSync:
    """Synchronize Markdown notes to Qdrant with hash-based change detection"""
    
    def __init__(self):
        self.qdrant = QdrantClient(url=QDRANT_URL)
        self.embedder = TextEmbedding(model_name=EMBEDDING_MODEL)
        self.cache = self.load_cache()
        self.stats = {
            "scanned": 0,
            "created": 0,
            "updated": 0,
            "deleted": 0,
            "unchanged": 0,
            "errors": 0
        }
    
    def load_cache(self) -> Dict:
        """Load sync cache from JSON file"""
        if os.path.exists(CACHE_FILE):
            try:
                with open(CACHE_FILE, 'r') as f:
                    return json.load(f)
            except Exception as e:
                logger.warning(f"Failed to load cache: {e}. Starting fresh.")
                return {}
        return {}
    
    def save_cache(self):
        """Save sync cache to JSON file"""
        try:
            os.makedirs(os.path.dirname(CACHE_FILE), exist_ok=True)
            with open(CACHE_FILE, 'w') as f:
                json.dump(self.cache, f, indent=2)
        except Exception as e:
            logger.error(f"Failed to save cache: {e}")
    
    def calculate_file_hash(self, file_path: str) -> str:
        """Calculate SHA256 hash of file content"""
        with open(file_path, 'rb') as f:
            return hashlib.sha256(f.read()).hexdigest()
    
    def parse_frontmatter(self, content: str) -> Tuple[Dict, str]:
        """Extract YAML frontmatter and content"""
        if content.startswith('---'):
            parts = content.split('---', 2)
            if len(parts) >= 3:
                try:
                    frontmatter = yaml.safe_load(parts[1])
                    return frontmatter or {}, parts[2].strip()
                except yaml.YAMLError:
                    pass
        return {}, content
    
    def chunk_text(self, text: str, chunk_size: int = CHUNK_SIZE, overlap: int = CHUNK_OVERLAP) -> List[str]:
        """Split text into overlapping chunks"""
        if len(text) <= chunk_size:
            return [text]
        
        chunks = []
        start = 0
        while start < len(text):
            end = start + chunk_size
            chunk = text[start:end]
            
            # Try to break at sentence boundary
            if end < len(text):
                last_period = chunk.rfind('.')
                last_newline = chunk.rfind('\n')
                break_point = max(last_period, last_newline)
                if break_point > chunk_size // 2:
                    chunk = chunk[:break_point + 1]
                    end = start + break_point + 1
            
            chunks.append(chunk.strip())
            start = end - overlap
        
        return [c for c in chunks if c]  # Remove empty chunks
    
    def generate_chunk_id(self, file_path: str, chunk_index: int) -> str:
        """Generate stable UUID-based chunk ID"""
        # Create deterministic UUID from file_path + chunk_index
        namespace = uuid.UUID('00000000-0000-0000-0000-000000000000')
        unique_string = f"{file_path}::{chunk_index}"
        return str(uuid.uuid5(namespace, unique_string))
    
    def delete_file_chunks(self, file_path: str):
        """Delete all chunks associated with a file"""
        try:
            # Get all points with this file_path
            scroll_result = self.qdrant.scroll(
                collection_name=COLLECTION_NAME,
                scroll_filter=Filter(
                    must=[FieldCondition(
                        key="file_path",
                        match=MatchValue(value=file_path)
                    )]
                ),
                limit=1000,
                with_payload=False,
                with_vectors=False
            )
            
            points_to_delete = [point.id for point in scroll_result[0]]
            
            if points_to_delete:
                self.qdrant.delete(
                    collection_name=COLLECTION_NAME,
                    points_selector=points_to_delete
                )
                logger.info(f"Deleted {len(points_to_delete)} chunks for {file_path}")
        except Exception as e:
            logger.error(f"Failed to delete chunks for {file_path}: {e}")
    
    def process_file(self, file_path: Path) -> bool:
        """Process a single Markdown file"""
        try:
            self.stats["scanned"] += 1
            relative_path = str(file_path.relative_to(NOTES_PATH))
            
            # Check if file changed
            current_mtime = file_path.stat().st_mtime
            current_hash = self.calculate_file_hash(str(file_path))
            
            cached = self.cache.get(relative_path, {})
            if cached.get("hash") == current_hash:
                self.stats["unchanged"] += 1
                logger.debug(f"Unchanged: {relative_path}")
                return True
            
            # File is new or modified
            is_new = relative_path not in self.cache
            action = "Creating" if is_new else "Updating"
            logger.info(f"{action}: {relative_path}")
            
            # Read and parse file
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            frontmatter, body = self.parse_frontmatter(content)
            
            # Delete old chunks if updating
            if not is_new:
                self.delete_file_chunks(relative_path)
            
            # Chunk the content
            chunks = self.chunk_text(body)
            
            # Embed chunks
            chunk_embeddings = list(self.embedder.embed(chunks))
            
            # Prepare points for Qdrant
            points = []
            for idx, (chunk, embedding) in enumerate(zip(chunks, chunk_embeddings)):
                point_id = self.generate_chunk_id(relative_path, idx)
                
                payload = {
                    "document": chunk,
                    "metadata": {
                        "file_path": relative_path,
                        "file_hash": current_hash,
                        "chunk_index": idx,
                        "chunk_total": len(chunks),
                        "last_synced": datetime.now().isoformat(),
                        "frontmatter": frontmatter
                    }
                }
                
                points.append(PointStruct(
                    id=point_id,
                    vector={"fast-bge-large-en-v1.5": embedding.tolist()},
                    payload=payload
                ))
            
            # Upsert to Qdrant
            self.qdrant.upsert(
                collection_name=COLLECTION_NAME,
                points=points
            )
            
            # Update cache
            self.cache[relative_path] = {
                "hash": current_hash,
                "mtime": current_mtime,
                "chunks": len(chunks),
                "last_synced": datetime.now().isoformat()
            }
            
            if is_new:
                self.stats["created"] += 1
            else:
                self.stats["updated"] += 1
            
            logger.info(f"✅ Synced {len(chunks)} chunks for {relative_path}")
            return True
            
        except Exception as e:
            self.stats["errors"] += 1
            logger.error(f"❌ Error processing {file_path}: {e}")
            return False
    
    def cleanup_deleted_files(self, current_files: set):
        """Remove chunks for files that no longer exist"""
        cached_files = set(self.cache.keys())
        deleted_files = cached_files - current_files
        
        for file_path in deleted_files:
            logger.info(f"Deleting chunks for removed file: {file_path}")
            self.delete_file_chunks(file_path)
            del self.cache[file_path]
            self.stats["deleted"] += 1
    
    def sync(self):
        """Main sync process"""
        logger.info("=" * 60)
        logger.info(f"Starting notes sync: {NOTES_PATH} → {COLLECTION_NAME}")
        logger.info("=" * 60)
        
        # Find all markdown files
        notes_path = Path(NOTES_PATH)
        if not notes_path.exists():
            logger.error(f"Notes directory not found: {NOTES_PATH}")
            return
        
        md_files = list(notes_path.rglob("*.md"))
        current_files = {str(f.relative_to(notes_path)) for f in md_files}
        
        logger.info(f"Found {len(md_files)} markdown files")
        
        # Process each file
        for md_file in md_files:
            self.process_file(md_file)
        
        # Cleanup deleted files
        self.cleanup_deleted_files(current_files)
        
        # Save cache
        self.save_cache()
        
        # Print summary
        logger.info("=" * 60)
        logger.info("Sync completed!")
        logger.info(f"  Scanned:   {self.stats['scanned']}")
        logger.info(f"  Created:   {self.stats['created']}")
        logger.info(f"  Updated:   {self.stats['updated']}")
        logger.info(f"  Deleted:   {self.stats['deleted']}")
        logger.info(f"  Unchanged: {self.stats['unchanged']}")
        logger.info(f"  Errors:    {self.stats['errors']}")
        logger.info("=" * 60)


if __name__ == "__main__":
    try:
        sync = NotesSync()
        sync.sync()
    except KeyboardInterrupt:
        logger.info("Sync interrupted by user")
        sys.exit(0)
    except Exception as e:
        logger.error(f"Fatal error: {e}", exc_info=True)
        sys.exit(1)

