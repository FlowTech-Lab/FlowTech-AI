# 📝 FlowTech-AI Notes - Guide d'utilisation

## 🎯 Structure

```
Notes/
├── _Templates/          # Templates pour nouvelles notes
│   ├── vm-template.md
│   ├── server-template.md
│   └── domain-template.md
│
├── _Indexes/            # Index auto-générés (ne pas éditer!)
│   ├── VMs-Index.md
│   ├── Servers-Index.md
│   └── Domains-Index.md
│
├── VMs/                 # Notes des VMs
├── Servers/             # Notes des serveurs
├── Domains/             # Notes des domaines
├── Projects/            # Notes de projets
└── Daily/               # Notes quotidiennes
```

## 🚀 Quick Start

### 1. Créer une nouvelle VM

```bash
# Copy template
cp _Templates/vm-template.md VMs/VM-001-MyApp.md

# Edit in Obsidian
# - Fill frontmatter (ip, ram, cpu, etc.)
# - Add description
# - Save
```

### 2. Synchronisation automatique

Toutes les 10 minutes, le système :
- ✅ Détecte les changements (hash MD5)
- ✅ Met à jour Qdrant RAG
- ✅ Régénère les index

### 3. Utilisation du RAG

**Dans OpenWebUI** :
```
User: "What is the IP of the database VM?"
AI: "The database VM (VM-002-Database) is at IP 192.168.1.101"
```

**Dans Cursor** :
```
@qdrant find information about VM 001
```

## 📋 Frontmatter requis

```yaml
---
type: vm | server | domain | project | note
name: Descriptive-Name
ip: 192.168.1.XXX            # (if applicable)
status: active | hold | done
created: 2025-10-18
updated: 2025-10-18          # Auto ou manuel
tags: [tag1, tag2, ...]
---
```

## 🔗 Bonnes pratiques

### Liens Obsidian

```markdown
- Reference a VM: [[VM-001-Example]]
- With alias: [[VM-001-Example|VM 001]]
- Reference section: [[VM-001-Example#Configuration]]
```

### Organisation

- **1 entité = 1 note** (VM, serveur, domaine)
- **Frontmatter complet** (pour index automatique)
- **Sections structurées** avec `##` niveau 2
- **Tags cohérents** (aide la recherche sémantique)

### Index auto-générés

⚠️ **Ne jamais éditer** les fichiers dans `_Indexes/` !
- Ils sont regénérés automatiquement
- Vos changements seront écrasés
- Modifier les frontmatters à la source à la place

## 🎯 Workflow recommandé

### Édition quotidienne

```
1. Ouvrir Obsidian
2. Créer/éditer vos notes
3. Sauvegarder (Ctrl+S)
4. Sync Nextcloud automatique
5. RAG update automatique (10 min max)
6. Interroger via OpenWebUI ou Cursor
```

### Création de nouvelle VM

```
1. Copier template
2. Remplir frontmatter
3. Ajouter description
4. Sauvegarder
5. Index auto-généré dans 10 min
6. Visible dans VMs-Index.md
```

## 🔍 Recherche sémantique

Le RAG permet des requêtes naturelles :

- "Quelles VMs ont plus de 32GB de RAM ?"
- "Quel serveur héberge Nextcloud ?"
- "Liste des domaines SSL actifs"
- "Configuration Docker sur VM 407"

## 📊 Collections Qdrant

| Collection | Contenu | Usage |
|------------|---------|-------|
| `notes-flowtech` | Vos notes Obsidian | OpenWebUI RAG |
| `cursor-context` | Snippets code Cursor | Cursor MCP |

**Séparation totale** = pas de pollution !

---

**⭐ Astuce** : Gardez vos frontmatters à jour, les index seront toujours corrects !

