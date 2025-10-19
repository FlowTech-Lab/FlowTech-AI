# 🚀 FlowTech-AI - Quick Start Guide

Start the complete stack in **5 minutes**!

## ⚡ Quick installation

```bash
# 1. Clone the repo
git clone https://github.com/flowtech/FlowTech-AI.git
cd FlowTech-AI

# 2. Configure (optional if default values OK)
cp .env.example .env
nano .env  # Adjust if necessary

# 3. Launch everything!
./init.sh

# ✅ That's it! Stack ready in 5 minutes
```

## 🎯 Available services

After `./init.sh`, you have access to:

| Service | URL | Description |
|---------|-----|-------------|
| **OpenWebUI** | http://localhost:8081 | Conversational AI interface |
| **Cursor MCP** | http://localhost:8000 | Cursor IDE integration |
| **n8n** | http://localhost:5678 | Automation workflows |
| **Qdrant** | http://localhost:6333 | Vector database |

**Credentials**: Displayed at the end of `init.sh`

## 🔧 Cursor Configuration

### 1. Copy MCP config

```bash
# Linux/Mac
cp config/mcp-config.json ~/.cursor/mcp.json

# Windows
copy config\mcp-config.json %USERPROFILE%\.cursor\mcp.json
```

### 2. Edit the IP

```json
{
  "mcpServers": {
    "qdrant": {
      "url": "http://YOUR_IP:8000/sse"  // ← Change the IP
    }
  }
}
```

### 3. Restart Cursor

### 4. Test

In Cursor:
```
@qdrant store "Test MCP connection"
@qdrant find test connection
```

✅ If it works, you're ready!

## 📝 Obsidian Configuration (optional)

### 1. Access to notes

**Option A - Samba network share** (RECOMMENDED for LAN):
```bash
# Enable Samba
docker compose up -d samba

# Windows: Open \\SERVER_IP\notes in Explorer
# Linux: sudo mount -t cifs //SERVER_IP/notes /mnt/notes
# macOS: Finder → Connect to Server → smb://SERVER_IP/notes

# Obsidian: Open network folder as vault
```
✅ Real-time, no sync needed
✅ Multi-user

**Option B - Local**:
- Local vault: `FlowTech-AI/Notes/`

**Option C - Nextcloud**:
- Sync with `/Flow-Notes-AI/Notes/`

See [docs/SAMBA-SHARE-GUIDE.md](docs/SAMBA-SHARE-GUIDE.md) for detailed configuration

### 2. Templates

Copy templates from `Notes/_Templates/`:
- `vm-template.md`
- `server-template.md`
- `domain-template.md`

### 3. Automatic sync

**Option A - Cron**:
```bash
# Every 10 minutes
*/10 * * * * cd /path/to/FlowTech-AI && python3 services/notes-sync/sync-obsidian.py
```

**Option B - n8n** (recommended):
- Create workflow in n8n (see `workflows/obsidian-sync/README.md`)
- Schedule trigger: 10 minutes

### 4. Test

```bash
# Create a test note
cp Notes/_Templates/vm-template.md Notes/VMs/VM-Test.md

# Edit frontmatter (ip, ram, etc.)

# Manual sync
python3 services/notes-sync/sync-obsidian.py

# Check Qdrant
curl http://localhost:6333/collections/notes-flowtech

# Query via OpenWebUI
# "What is the IP of VM-Test?"
```

## 🎯 Use cases

### Developer with Cursor

```
1. Code in Cursor
2. @qdrant store to save snippets
3. @qdrant find to retrieve context
4. RAG enriched with your technical notes
```

### Technical notes management

```
1. Edit notes in Obsidian
2. Automatic sync (10 min)
3. Auto-generated indexes
4. Query via OpenWebUI
```

### Team (fork)

```
1. Clone the repo
2. ./init.sh
3. Configure Obsidian/Cursor
4. Everyone shares the same knowledge base
```

## 📊 Verification

### Stack operational?

```bash
docker compose ps
# ✅ All services "Up (healthy)"
```

### MCP-Qdrant working?

```bash
curl http://localhost:8000/sse
# ✅ Returns event stream
```

### Qdrant collections?

```bash
curl http://localhost:6333/collections
# ✅ See "cursor-context" and "notes-flowtech"
```

## 🆘 Troubleshooting

### Services not starting

```bash
# Check logs
docker compose logs

# Restart cleanly
docker compose down
./init.sh
```

### Cursor not connecting

```bash
# Check IP in ~/.cursor/mcp.json
# Check firewall
sudo ufw allow 8000

# Test endpoint
curl http://YOUR_IP:8000/sse
```

### Notes not synchronized

```bash
# Manual test
cd services/notes-sync
python sync-obsidian.py

# Check NOTES_PATH
echo $NOTES_PATH

# Check collection
curl http://localhost:6333/collections/notes-flowtech
```

## 📚 Complete documentation

- **Setup**: `docs/setup/` - Detailed installation
- **Architecture**: `docs/architecture/` - Technical overview
- **Services**: `docs/services/` - Service documentation
- **Notes**: `Notes/README-NOTES.md` - Notes guide

## 🎉 That's it!

You now have:
- ✅ Complete operational AI stack
- ✅ Cursor integration (MCP-Qdrant)
- ✅ OpenWebUI with RAG
- ✅ Automatic notes sync
- ✅ Auto-generated indexes

**Total time**: ~5 minutes ⚡

---

**Next steps**: See [README.md](README.md) to go further!

