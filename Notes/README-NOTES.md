# 📝 Notes Templates for Obsidian

This directory contains **generic templates** for organizing your technical notes in Obsidian.

## 🎯 Purpose

These templates help you maintain consistent documentation for:
- 🖥️ Virtual Machines
- 🖧 Servers
- 🌐 Domains
- 📁 Projects

## 📁 Directory Structure

```
Notes/
├── _Templates/           # ← Templates (included in repo)
│   ├── vm-template.md
│   ├── server-template.md
│   └── domain-template.md
│
└── README-NOTES.md      # ← This file
```

## 🚀 Quick Start

### 1. Open in Obsidian

- **Option A**: Use `Notes/` folder as vault
- **Option B**: Link this folder to your existing vault

### 2. Use Templates

1. Copy a template from `_Templates/`
2. Rename it (e.g., `VM-WebServer-01.md`)
3. Fill in the frontmatter metadata
4. Add your content

### 3. Example Usage

```markdown
---
type: vm
name: WebServer-01
ip: 192.168.1.100
ram_gib: 8
cpu: 4
status: active
services:
  - nginx
  - postgresql
created: 2025-01-15
---

# WebServer-01

## Description
Production web server hosting main application.

## Configuration
- OS: Ubuntu 22.04
- Docker: Yes
- Backup: Daily at 2 AM

## Access
ssh admin@192.168.1.100
```

## 🔗 Integration with FlowTech-AI

### Manual Upload to OpenWebUI

1. Save your notes
2. Open http://localhost:8081
3. Create a chat
4. Click **"Knowledge"** → **"Upload Files"**
5. Select your .md files
6. Ask questions about your infrastructure!

### Advanced: Automated Sync

For automated synchronization with Qdrant (RAG), see:
👉 **[Flow-Notes-AI](https://github.com/FlowTech-Lab/Flow-Notes-AI)** - Companion repo with sync scripts

## 📋 Template Fields

### VM Template
- `type`: vm
- `name`: Machine name
- `ip`: IP address
- `ram_gib`: RAM in GB
- `cpu`: Number of CPUs
- `status`: active/inactive/maintenance
- `services`: List of running services

### Server Template
- `type`: server
- `name`: Server name
- `ip`: IP address
- `server_type`: web/db/app/etc
- `status`: active/inactive/maintenance
- `services`: List of services

### Domain Template
- `type`: domain
- `name`: Domain name
- `ip`: Resolved IP
- `domain_type`: public/internal
- `status`: active/expired/pending
- `services`: Associated services

## 🎨 Customization

Feel free to customize templates for your needs:

1. Add more fields in frontmatter
2. Create new templates for other resource types
3. Modify sections structure
4. Add diagrams with Mermaid

Example custom field:
```yaml
---
type: vm
name: MyVM
tags: [production, critical, web]
owner: dev-team
backup_strategy: daily
monitoring: prometheus
---
```

## 📚 Best Practices

✅ **Consistent naming**: Use a naming convention (e.g., `VM-WebServer-01`)  
✅ **Tags**: Use frontmatter tags for easy filtering  
✅ **Links**: Use `[[links]]` to connect related notes  
✅ **Update dates**: Keep `updated:` field current  
✅ **Status**: Always maintain status field  

## 🔍 Search & Query

With Obsidian:
- Search by tags: `tag:#production`
- Dataview queries: Extract data from frontmatter
- Graph view: Visualize connections

With OpenWebUI RAG:
- "Show me all production VMs"
- "Which servers need maintenance?"
- "What services run on 192.168.1.100?"

## 🤝 Contributing

Found a useful template structure? Feel free to:
1. Fork FlowTech-AI
2. Add your template to `_Templates/`
3. Submit a pull request

---

**Happy note-taking! 📝**
