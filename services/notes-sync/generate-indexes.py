#!/usr/bin/env python3
"""
FlowTech-AI Index Generator
Génère automatiquement les index (VMs, Servers, Domains) depuis les frontmatters
"""

import os
import re
import sys
import yaml
from datetime import datetime
from pathlib import Path
from typing import Dict, List
from collections import defaultdict


# ========================================
# CONFIGURATION
# ========================================

class Config:
    """Configuration du générateur d'index"""
    NOTES_PATH = Path(os.getenv("NOTES_PATH", "/app/notes"))
    INDEXES_PATH = NOTES_PATH / "_Indexes"
    
    # Types de notes à indexer
    INDEX_TYPES = {
        "vm": {"folder": "VMs", "title": "Virtual Machines", "icon": "🖥️"},
        "server": {"folder": "Servers", "title": "Servers", "icon": "🖧"},
        "domain": {"folder": "Domains", "title": "Domains", "icon": "🌐"},
        "project": {"folder": "Projects", "title": "Projects", "icon": "📁"},
    }


# ========================================
# GÉNÉRATEUR D'INDEX
# ========================================

class IndexGenerator:
    """Génère les fichiers d'index automatiquement"""
    
    def __init__(self):
        self.notes_by_type = defaultdict(list)
    
    def parse_frontmatter(self, file_path: Path) -> Dict:
        """Parse le frontmatter YAML d'un fichier"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            pattern = r'^---\s*\n(.*?)\n---\s*\n'
            match = re.match(pattern, content, re.DOTALL)
            
            if match:
                metadata = yaml.safe_load(match.group(1))
                return metadata or {}
        except Exception as e:
            print(f"⚠️  Erreur parsing {file_path.name}: {e}")
        
        return {}
    
    def scan_notes(self):
        """Scanne toutes les notes et les regroupe par type"""
        print(f"📂 Scan du répertoire : {Config.NOTES_PATH}")
        
        for md_file in Config.NOTES_PATH.rglob("*.md"):
            # Ignorer dossiers spéciaux
            if any(part.startswith('_') or part.startswith('.') for part in md_file.parts):
                continue
            
            metadata = self.parse_frontmatter(md_file)
            note_type = metadata.get('type', 'unknown')
            
            if note_type in Config.INDEX_TYPES:
                rel_path = md_file.relative_to(Config.NOTES_PATH)
                note_info = {
                    "path": str(rel_path),
                    "name": md_file.stem,
                    "metadata": metadata
                }
                self.notes_by_type[note_type].append(note_info)
        
        print(f"✅ Notes trouvées: {sum(len(notes) for notes in self.notes_by_type.values())}")
        for note_type, notes in self.notes_by_type.items():
            print(f"   - {note_type}: {len(notes)}")
    
    def generate_vm_index(self) -> str:
        """Génère l'index des VMs"""
        vms = sorted(self.notes_by_type.get('vm', []), 
                    key=lambda x: x['metadata'].get('name', ''))
        
        lines = [
            "---",
            "type: index",
            "category: vms",
            "auto_generated: true",
            f"updated: {datetime.utcnow().isoformat()}Z",
            "---",
            "",
            "# 🖥️ Index des Virtual Machines",
            "",
            f"**Total : {len(vms)} VMs**",
            "",
            "| VM | IP | RAM | CPU | Services | Status | Fichier |",
            "|----|----|-----|-----|----------|--------|---------|"
        ]
        
        for vm in vms:
            meta = vm['metadata']
            name = meta.get('name', vm['name'])
            ip = meta.get('ip', 'N/A')
            ram = meta.get('ram_gib', meta.get('ram', 'N/A'))
            cpu = meta.get('cpu', 'N/A')
            services = ', '.join(meta.get('services', []))[:30]
            status = meta.get('status', 'unknown')
            link = f"[[{vm['name']}]]"
            
            lines.append(f"| {name} | {ip} | {ram}GB | {cpu} | {services} | {status} | {link} |")
        
        lines.extend([
            "",
            "---",
            f"*Auto-généré le {datetime.now().strftime('%Y-%m-%d %H:%M:%S')} - Ne pas éditer manuellement*"
        ])
        
        return "\n".join(lines)
    
    def generate_server_index(self) -> str:
        """Génère l'index des serveurs"""
        servers = sorted(self.notes_by_type.get('server', []),
                        key=lambda x: x['metadata'].get('name', ''))
        
        lines = [
            "---",
            "type: index",
            "category: servers",
            "auto_generated: true",
            f"updated: {datetime.utcnow().isoformat()}Z",
            "---",
            "",
            "# 🖧 Index des Serveurs",
            "",
            f"**Total : {len(servers)} serveurs**",
            "",
            "| Serveur | IP | Type | Status | Fichier |",
            "|---------|----|----|--------|---------|"
        ]
        
        for server in servers:
            meta = server['metadata']
            name = meta.get('name', server['name'])
            ip = meta.get('ip', 'N/A')
            srv_type = meta.get('server_type', 'N/A')
            status = meta.get('status', 'unknown')
            link = f"[[{server['name']}]]"
            
            lines.append(f"| {name} | {ip} | {srv_type} | {status} | {link} |")
        
        lines.extend([
            "",
            "---",
            f"*Auto-généré le {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*"
        ])
        
        return "\n".join(lines)
    
    def generate_domain_index(self) -> str:
        """Génère l'index des domaines"""
        domains = sorted(self.notes_by_type.get('domain', []),
                        key=lambda x: x['metadata'].get('name', ''))
        
        lines = [
            "---",
            "type: index",
            "category: domains",
            "auto_generated: true",
            f"updated: {datetime.utcnow().isoformat()}Z",
            "---",
            "",
            "# 🌐 Index des Domaines",
            "",
            f"**Total : {len(domains)} domaines**",
            "",
            "| Domaine | IP | Type | Status | Fichier |",
            "|---------|----|----|--------|---------|"
        ]
        
        for domain in domains:
            meta = domain['metadata']
            name = meta.get('name', domain['name'])
            ip = meta.get('ip', 'N/A')
            dom_type = meta.get('domain_type', 'N/A')
            status = meta.get('status', 'unknown')
            link = f"[[{domain['name']}]]"
            
            lines.append(f"| {name} | {ip} | {dom_type} | {status} | {link} |")
        
        lines.extend([
            "",
            "---",
            f"*Auto-généré le {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*"
        ])
        
        return "\n".join(lines)
    
    def save_index(self, filename: str, content: str):
        """Sauvegarde un fichier d'index"""
        Config.INDEXES_PATH.mkdir(parents=True, exist_ok=True)
        index_path = Config.INDEXES_PATH / filename
        
        with open(index_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print(f"✅ Index généré : {filename}")
    
    def generate_all(self):
        """Génère tous les index"""
        print("=" * 80)
        print("📋 FlowTech-AI Index Generator")
        print("=" * 80)
        
        # Scan
        self.scan_notes()
        
        # Génération
        print("\n📝 Génération des index...")
        
        if 'vm' in self.notes_by_type:
            self.save_index("VMs-Index.md", self.generate_vm_index())
        
        if 'server' in self.notes_by_type:
            self.save_index("Servers-Index.md", self.generate_server_index())
        
        if 'domain' in self.notes_by_type:
            self.save_index("Domains-Index.md", self.generate_domain_index())
        
        print("\n✅ Tous les index ont été générés !")
        print("=" * 80)


# ========================================
# MAIN
# ========================================

def main():
    """Point d'entrée"""
    try:
        generator = IndexGenerator()
        generator.generate_all()
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

