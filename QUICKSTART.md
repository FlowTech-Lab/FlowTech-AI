# 🚀 FlowTech-AI - Quick Start Guide

Start the complete stack in **5 minutes**!

## ⚡ Quick installation

```bash
# 1. Clone the repo
git clone https://github.com/FlowTech-Lab/FlowTech-AI.git
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
cp cursor-mcp-config.json ~/.cursor/mcp.json

# Windows
copy cursor-mcp-config.json %USERPROFILE%\.cursor\mcp.json
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

## 📚 Using OpenWebUI RAG

### 1. Open OpenWebUI

Navigate to http://localhost:8081

### 2. Create a Chat

Click on "New Chat"

### 3. Enable Knowledge

Click the **"Knowledge"** button in the chat interface

### 4. Upload Documents

- Click **"Upload Files"**
- Select your documents (PDF, DOCX, MD, TXT, etc.)
- Wait for indexing (automatic)

### 5. Ask Questions

```
User: What does the technical documentation say about database setup?
AI: Based on the uploaded documentation, the database setup involves...
```

### Supported Formats

- 📄 Documents: PDF, DOCX, TXT, MD
- 💻 Code: PY, JS, TS, JAVA, etc.
- 🌐 Web: Paste URLs for website indexing

## 🎯 Use cases

### Developer with Cursor

```
1. Code in Cursor
2. @qdrant store to save snippets
3. @qdrant find to retrieve context
4. RAG enriched with your technical notes
```

### Technical documentation Q&A

```
1. Upload docs to OpenWebUI
2. Ask questions in natural language
3. Get accurate answers with citations
4. Share knowledge with your team
```

### Team (fork)

```
1. Clone the repo
2. ./init.sh
3. Configure Cursor
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
# ✅ See "cursor-context"
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

### RAG not finding documents

```bash
# Check OpenWebUI logs
docker compose logs openwebui

# Verify Qdrant collection
curl http://localhost:6333/collections

# Re-upload documents in OpenWebUI
```

## 📚 Complete documentation

- **Setup**: `README.md` - Detailed installation
- **Architecture**: See README.md - Technical overview
- **Services**: docker-compose.yml - Service configuration
- **Templates**: `Notes/_Templates/` - Obsidian templates

## 🎉 That's it!

You now have:
- ✅ Complete operational AI stack
- ✅ Cursor integration (MCP-Qdrant)
- ✅ OpenWebUI with RAG
- ✅ Vector database ready
- ✅ Automation platform (n8n)

**Total time**: ~5 minutes ⚡

---

**Next steps**: See [README.md](README.md) to go further!
