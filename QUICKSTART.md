# 🚀 FlowTech-AI - Quick Start Guide

Démarrez la stack complète en **5 minutes** !

## ⚡ Installation rapide

```bash
# 1. Clone le repo
git clone https://github.com/flowtech/FlowTech-AI.git
cd FlowTech-AI

# 2. Configure (optionnel si valeurs par défaut OK)
cp .env.example .env
nano .env  # Ajuster si nécessaire

# 3. Lance tout !
./init.sh

# ✅ C'est tout ! Stack prête en 5 minutes
```

## 🎯 Services disponibles

Après `./init.sh`, vous avez accès à :

| Service | URL | Description |
|---------|-----|-------------|
| **OpenWebUI** | http://localhost:8081 | Interface IA conversationnelle |
| **Cursor MCP** | http://localhost:8000 | Integration Cursor IDE |
| **n8n** | http://localhost:5678 | Automation workflows |
| **Qdrant** | http://localhost:6333 | Vector database |

**Credentials** : Affichés à la fin de `init.sh`

## 🔧 Configuration Cursor

### 1. Copier la config MCP

```bash
# Linux/Mac
cp config/mcp-config.json ~/.cursor/mcp.json

# Windows
copy config\mcp-config.json %USERPROFILE%\.cursor\mcp.json
```

### 2. Éditer l'IP

```json
{
  "mcpServers": {
    "qdrant": {
      "url": "http://VOTRE_IP:8000/sse"  // ← Changer l'IP
    }
  }
}
```

### 3. Redémarrer Cursor

### 4. Tester

Dans Cursor :
```
@qdrant store "Test de la connexion MCP"
@qdrant find test connexion
```

✅ Si ça fonctionne, vous êtes prêt !

## 📝 Configuration Obsidian (optionnel)

### 1. Structure des notes

Créez un vault Obsidian pointant vers :
- **Local** : `FlowTech-AI/Notes/`
- **Nextcloud** : Sync avec `/Flow-Notes-AI/Notes/`

### 2. Templates

Copiez les templates depuis `Notes/_Templates/` :
- `vm-template.md`
- `server-template.md`
- `domain-template.md`

### 3. Sync automatique

**Option A - Cron** :
```bash
# Toutes les 10 min
*/10 * * * * cd /path/to/FlowTech-AI && python3 services/notes-sync/sync-obsidian.py
```

**Option B - n8n** (recommandé) :
- Créer workflow dans n8n (voir `workflows/obsidian-sync/README.md`)
- Schedule trigger: 10 minutes

### 4. Test

```bash
# Créer une note de test
cp Notes/_Templates/vm-template.md Notes/VMs/VM-Test.md

# Éditer frontmatter (ip, ram, etc.)

# Sync manuel
python3 services/notes-sync/sync-obsidian.py

# Vérifier Qdrant
curl http://localhost:6333/collections/notes-flowtech

# Interroger via OpenWebUI
# "Quelle est l'IP de VM-Test ?"
```

## 🎯 Cas d'usage

### Développeur avec Cursor

```
1. Coder dans Cursor
2. @qdrant store pour sauver snippets
3. @qdrant find pour retrouver contexte
4. RAG enrichi avec vos notes techniques
```

### Gestion de notes techniques

```
1. Éditer notes dans Obsidian
2. Sync automatique (10 min)
3. Index auto-générés
4. Interroger via OpenWebUI
```

### Équipe (fork)

```
1. Clone le repo
2. ./init.sh
3. Configure Obsidian/Cursor
4. Tout le monde partage la même base de connaissance
```

## 📊 Vérification

### Stack opérationnelle ?

```bash
docker compose ps
# ✅ Tous les services "Up (healthy)"
```

### MCP-Qdrant fonctionne ?

```bash
curl http://localhost:8000/sse
# ✅ Retourne event stream
```

### Qdrant collections ?

```bash
curl http://localhost:6333/collections
# ✅ Voir "cursor-context" et "notes-flowtech"
```

## 🆘 Troubleshooting

### Services ne démarrent pas

```bash
# Vérifier logs
docker compose logs

# Redémarrer proprement
docker compose down
./init.sh
```

### Cursor ne se connecte pas

```bash
# Vérifier IP dans ~/.cursor/mcp.json
# Vérifier firewall
sudo ufw allow 8000

# Tester endpoint
curl http://VOTRE_IP:8000/sse
```

### Notes pas synchronisées

```bash
# Test manuel
cd services/notes-sync
python sync-obsidian.py

# Vérifier NOTES_PATH
echo $NOTES_PATH

# Vérifier collection
curl http://localhost:6333/collections/notes-flowtech
```

## 📚 Documentation complète

- **Setup** : `docs/setup/` - Installation détaillée
- **Architecture** : `docs/architecture/` - Vue technique
- **Services** : `docs/services/` - Doc par service
- **Notes** : `Notes/README-NOTES.md` - Guide notes

## 🎉 Et voilà !

Vous avez maintenant :
- ✅ Stack IA complète opérationnelle
- ✅ Cursor integration (MCP-Qdrant)
- ✅ OpenWebUI avec RAG
- ✅ Sync notes automatique
- ✅ Index auto-générés

**Temps total** : ~5 minutes ⚡

---

**Prochaines étapes** : Voir [README.md](README.md) pour aller plus loin !

