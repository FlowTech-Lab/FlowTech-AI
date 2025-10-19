#!/usr/bin/env python3
"""
FlowTech-AI Index Generator
Automatically generates indexes (VMs, Servers, Domains) from frontmatters
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
    """Index generator configuration"""
    NOTES_PATH = Path(os.getenv("NOTES_PATH", "/app/notes"))
    INDEXES_PATH = NOTES_PATH / "_Indexes"
    
    # Note types to index
    INDEX_TYPES = {
        "vm": {"folder": "VMs", "title": "Virtual Machines", "icon": "🖥️"},
        "server": {"folder": "Servers", "title": "Servers", "icon": "🖧"},
        "domain": {"folder": "Domains", "title": "Domains", "icon": "🌐"},
        "project": {"folder": "Projects", "title": "Projects", "icon": "📁"},
    }


# ========================================
# INDEX GENERATOR
# ========================================

class IndexGenerator:
    """Automatically generates index files"""
    
    def __init__(self):
        self.notes_by_type = defaultdict(list)
    
    def parse_frontmatter(self, file_path: Path) -> Dict:
        """Parse YAML frontmatter from a file"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            pattern = r'^---\s*\n(.*?)\n---\s*\n'
            match = re.match(pattern, content, re.DOTALL)
            
            if match:
                metadata = yaml.safe_load(match.group(1))
                return metadata or {}
        except Exception as e:
            print(f"⚠️  Parsing error {file_path.name}: {e}")
        
        return {}
    
    def scan_notes(self):
        """Scan all notes and group them by type"""
        print(f"📂 Directory scan: {Config.NOTES_PATH}")
        
        for md_file in Config.NOTES_PATH.rglob("*.md"):
            # Ignore special directories
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
        
        print(f"✅ Notes found: {sum(len(notes) for notes in self.notes_by_type.values())}")
        for note_type, notes in self.notes_by_type.items():
            print(f"   - {note_type}: {len(notes)}")
    
    def generate_vm_index(self) -> str:
        """Generate VMs index"""
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
            "# 🖥️ Virtual Machines Index",
            "",
            f"**Total : {len(vms)} VMs**",
            "",
            "| VM | IP | RAM | CPU | Services | Status | File |",
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
            f"*Auto-generated on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')} - Do not edit manually*"
        ])
        
        return "\n".join(lines)
    
    def generate_server_index(self) -> str:
        """Generate servers index"""
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
            "# 🖧 Servers Index",
            "",
            f"**Total : {len(servers)} servers**",
            "",
            "| Server | IP | Type | Status | File |",
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
            f"*Auto-generated on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*"
        ])
        
        return "\n".join(lines)
    
    def generate_domain_index(self) -> str:
        """Generate domains index"""
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
            "# 🌐 Domains Index",
            "",
            f"**Total : {len(domains)} domains**",
            "",
            "| Domain | IP | Type | Status | File |",
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
            f"*Auto-generated on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*"
        ])
        
        return "\n".join(lines)
    
    def save_index(self, filename: str, content: str):
        """Save an index file"""
        Config.INDEXES_PATH.mkdir(parents=True, exist_ok=True)
        index_path = Config.INDEXES_PATH / filename
        
        with open(index_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print(f"✅ Index generated: {filename}")
    
    def generate_all(self):
        """Generate all indexes"""
        print("=" * 80)
        print("📋 FlowTech-AI Index Generator")
        print("=" * 80)
        
        # Scan
        self.scan_notes()
        
        # Generation
        print("\n📝 Generating indexes...")
        
        if 'vm' in self.notes_by_type:
            self.save_index("VMs-Index.md", self.generate_vm_index())
        
        if 'server' in self.notes_by_type:
            self.save_index("Servers-Index.md", self.generate_server_index())
        
        if 'domain' in self.notes_by_type:
            self.save_index("Domains-Index.md", self.generate_domain_index())
        
        print("\n✅ All indexes have been generated!")
        print("=" * 80)


# ========================================
# MAIN
# ========================================

def main():
    """Entry point"""
    try:
        generator = IndexGenerator()
        generator.generate_all()
    except KeyboardInterrupt:
        print("\n⚠️  User interruption")
        sys.exit(130)
    except Exception as e:
        print(f"\n❌ Fatal error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()

