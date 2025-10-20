# 📝 Notes Synchronization to Qdrant

Automatic synchronization system for Markdown notes to Qdrant vector database for RAG in Cursor.

---

## 🎯 Purpose

This system automatically syncs your Markdown notes from `Notes/` folder to Qdrant's `cursor-knowledge` collection, making them searchable via Cursor's MCP integration.

### Architecture

```
Notes/                          → Markdown files (Obsidian compatible)
    ↓ (hourly scan)
sync-notes-to-qdrant.py        → Parse, chunk, embed with FastEmbed
    ↓
Qdrant (cursor-knowledge)      → Vector storage
    ↓
MCP-Qdrant-Knowledge (port 8001) → Read-only access for Cursor
    ↓
Cursor IDE                      → Semantic search in your notes
```

---

## 🚀 Quick Start

### 1. Initial Sync (Manual)

```bash
cd /home/flowtech/FlowTech-LAB/FlowTech-AI
./scripts/sync-notes.sh
```

**Expected output:**
```
============================================================
Starting notes sync: ./Notes → cursor-knowledge
============================================================
Found 7 markdown files
Creating: VMs/VM-Example-WebServer.md
✅ Synced 3 chunks for VMs/VM-Example-WebServer.md
...
============================================================
Sync completed!
  Scanned:   7
  Created:   7
  Updated:   0
  Deleted:   0
  Unchanged: 0
  Errors:    0
============================================================
```

### 2. Install Hourly Cron Job

```bash
cd /home/flowtech/FlowTech-LAB/FlowTech-AI
./scripts/install-cron.sh
```

This will run the sync **every hour** automatically.

---

## 📊 How It Works

### 1. Change Detection (Hash-Based)

The system maintains a cache file (`AI_Data/notes-sync-cache.json`) that tracks:
- File hash (SHA256)
- Last modification time
- Number of chunks
- Last sync timestamp

**On each run:**
1. Scan `Notes/**/*.md` files
2. Compare file hash with cache
3. If changed → re-sync
4. If unchanged → skip

### 2. Chunking Strategy

```python
CHUNK_SIZE = 800        # characters per chunk
CHUNK_OVERLAP = 100     # overlap for context
```

- Splits at sentence boundaries when possible
- Maintains context with overlap
- Each chunk tagged with file path and index

### 3. Embedding

- Model: `BAAI/bge-large-en-v1.5` (same as MCP-Qdrant)
- Dimensions: 1024
- Provider: FastEmbed (local, no API calls)

### 4. Update Strategy

**For modified files:**
1. Delete all existing chunks (filtered by `file_path`)
2. Re-chunk the new content
3. Re-embed all chunks
4. Insert with deterministic UUIDs

**For deleted files:**
- Detected by comparing cache vs filesystem
- All associated chunks removed from Qdrant

---

## 🔍 Data Structure

### Qdrant Point Payload

```json
{
  "document": "Chunk content here...",
  "metadata": {
    "file_path": "VMs/VM-Example-WebServer.md",
    "file_hash": "abc123...",
    "chunk_index": 0,
    "chunk_total": 3,
    "last_synced": "2025-10-19T23:24:14.731Z",
    "frontmatter": {
      "vm_name": "WebServer",
      "ip": "192.168.1.100",
      "status": "active"
    }
  }
}
```

### Cache File Structure

```json
{
  "VMs/VM-Example-WebServer.md": {
    "hash": "sha256_hex_digest",
    "mtime": 1697000000.123,
    "chunks": 3,
    "last_synced": "2025-10-19T23:24:14.731Z"
  }
}
```

---

## 🛠️ Configuration

### Environment Variables

```bash
# Qdrant connection
QDRANT_URL=http://localhost:6333
COLLECTION_NAME=cursor-knowledge

# Embedding model
EMBEDDING_MODEL=BAAI/bge-large-en-v1.5

# Paths
NOTES_PATH=./Notes
CACHE_FILE=./AI_Data/notes-sync-cache.json

# Chunking
CHUNK_SIZE=800
CHUNK_OVERLAP=100
```

### Custom Configuration

Edit `scripts/sync-notes.sh` to change defaults:
```bash
export CHUNK_SIZE="1000"
export CHUNK_OVERLAP="150"
```

---

## 📋 Usage in Cursor

### Two MCP Servers

You have **two separate collections**:

1. **cursor-context** (port 8000) - Code context
   - Used by `@qdrant` tool
   - Read/Write access
   - For code snippets, documentation

2. **cursor-knowledge** (port 8001) - Personal notes
   - Used by `@qdrant-knowledge` tool
   - Read-only in Cursor (write via sync script)
   - For your Markdown notes

### Searching Notes in Cursor

```
User: @qdrant-knowledge find information about my web server VM
Cursor: [searches in cursor-knowledge collection]

User: What's the IP of my database server?
Cursor: [can search cursor-knowledge for server configurations]
```

**Note:** Currently both MCP servers expose the same tool names, so Cursor might default to the first one. You can specify which collection to search by using the correct MCP server in your queries.

---

## 🧪 Testing

### Manual Test

```bash
# Run sync manually
cd /home/flowtech/FlowTech-LAB/FlowTech-AI
./scripts/sync-notes.sh

# Check results
curl -s "http://localhost:6333/collections/cursor-knowledge" | jq '.result.points_count'
```

### Verify in Qdrant

```bash
# List all synced files
curl -s -X POST "http://localhost:6333/collections/cursor-knowledge/points/scroll" \
  -H "Content-Type: application/json" \
  -d '{"limit": 100, "with_payload": true, "with_vector": false}' \
  | jq -r '.result.points[].payload.metadata.file_path' | sort -u
```

### Check Logs

```bash
# Cron job logs
tail -f logs/notes-sync.log

# Manual run (verbose)
cd /home/flowtech/FlowTech-LAB/FlowTech-AI
NOTES_PATH=./Notes ./scripts/venv/bin/python ./scripts/sync-notes-to-qdrant.py
```

---

## 🔧 Maintenance

### Force Re-sync All Files

```bash
# Delete cache
rm AI_Data/notes-sync-cache.json

# Run sync
./scripts/sync-notes.sh
```

### Update Sync Frequency

```bash
# Edit crontab
crontab -e

# Change from hourly to every 30 minutes:
# */30 * * * * /path/to/sync-notes.sh >> /path/to/logs/notes-sync.log 2>&1
```

### Uninstall Cron Job

```bash
crontab -l | grep -v "sync-notes.sh" | crontab -
```

---

## ⚠️ Troubleshooting

### "Collection not found"

```bash
# Check if cursor-knowledge collection exists
curl -s "http://localhost:6333/collections/cursor-knowledge"

# If not, run init.sh to create it
cd /home/flowtech/FlowTech-LAB/FlowTech-AI
./init.sh
```

### "Permission denied" on cache file

```bash
# Fix permissions
chmod 644 AI_Data/notes-sync-cache.json
chown $USER:$USER AI_Data/notes-sync-cache.json
```

### Sync not running automatically

```bash
# Check cron service
systemctl status cron

# Check crontab
crontab -l

# Check logs
tail -f logs/notes-sync.log
```

### High memory usage

The FastEmbed model uses ~1-2GB RAM. If this is a problem:
- Reduce `CHUNK_SIZE` to process fewer chunks at once
- Consider using a smaller embedding model

---

## 📚 Related Documentation

- [MCP-Qdrant Guide](./MCP-QDRANT.md) - Cursor integration
- [Notes Templates](../Notes/README-NOTES.md) - Obsidian templates
- [Main README](../README.md) - FlowTech-AI overview

---

**Last Updated:** 2025-10-19  
**Status:** ✅ Production Ready

