# 📝 Flow-Notes-AI - Setup Guide (Companion Repo)

**FlowTech-AI** fournit l'infrastructure générique.  
**Flow-Notes-AI** contient VOS données personnelles et workflows configurés.

---

## 🎯 Séparation des responsabilités

### FlowTech-AI (PUBLIC - ce repo)
- ✅ Infrastructure Docker (docker-compose.yml)
- ✅ Services génériques (MCP-Qdrant, sync scripts)
- ✅ Templates exemples
- ✅ Documentation générique
- ❌ AUCUNE donnée personnelle

### Flow-Notes-AI (PRIVÉ - votre repo)
- ✅ Vos notes réelles
- ✅ Vos workflows n8n configurés
- ✅ Vos configs production
- ✅ Vos données sensibles

---

## 📁 Structure recommandée Flow-Notes-AI

```
Flow-Notes-AI/  (Repo privé, vos données)
├── Notes/                          # VOS notes (exclues de Git)
│   ├── _Indexes/                   # Auto-généré par scripts
│   ├── VMs/                        # Vos VMs
│   ├── Servers/                    # Vos serveurs
│   ├── Domains/                    # Vos domaines
│   └── Projects/                   # Vos projets
│
├── workflows/                      # VOS workflows n8n
│   ├── obsidian-sync/             # Workflow perso
│   ├── agent-00-pre-process/      # Si utilisé
│   └── ...
│
├── config/
│   ├── production.env             # VOS configs
│   └── aliases.yml                # Vos alias perso
│
├── .gitignore                     # Exclure Notes/
├── .env                           # Config locale
└── README.md                      # Usage personnel
```

---

## 🔧 Setup Flow-Notes-AI

### 1. Créer le repo (vierge)

```bash
# Option A : Nouveau repo Git
mkdir Flow-Notes-AI
cd Flow-Notes-AI
git init

# Option B : Nettoyer repo existant
cd Flow-Notes-AI
git checkout -b v2-clean --orphan
# Supprimer tout
git rm -rf .
```

### 2. Créer structure

```bash
mkdir -p Notes/{VMs,Servers,Domains,Projects,_Indexes}
mkdir -p workflows config
```

### 3. .gitignore (important!)

```
# Notes personnelles (NE PAS commit)
Notes/VMs/
Notes/Servers/
Notes/Domains/
Notes/Projects/
Notes/_Indexes/

# Garder structure vide
!Notes/.gitkeep

# Configs sensibles
.env
config/production.env
*.key

# Data
AI_Data/
logs/
```

### 4. README.md

```markdown
# Flow-Notes-AI

Personal implementation of FlowTech-AI stack.

## Setup

1. Clone FlowTech-AI (base stack)
2. Point this repo to FlowTech-AI services
3. Configure workflows
4. Start syncing notes

## Structure

- `Notes/` : My personal notes (not in Git)
- `workflows/` : My n8n workflows
- `config/` : My production configs
```

### 5. Lien vers FlowTech-AI

**Option A - Docker Compose extend** :
```yaml
# docker-compose.override.yml dans Flow-Notes-AI
version: "3.8"

# Utilise les services de FlowTech-AI
# Ajoute seulement volumes personnels
services:
  notes-sync:
    volumes:
      - ./Notes:/app/notes
```

**Option B - Variables d'env** :
```bash
# .env dans Flow-Notes-AI
FLOWTECH_AI_PATH=../FlowTech-AI
NOTES_PATH=$(pwd)/Notes
```

---

## 🚀 Workflow quotidien

### Édition notes

```
1. Éditer dans Obsidian
2. Sync Nextcloud (si configuré)
3. Sync auto vers Qdrant (toutes les 10 min)
```

### Interrogation

```
- OpenWebUI : Questions sur vos notes
- Cursor : Recherche contexte via @qdrant
```

---

## 📋 Ce qui vient de FlowTech-AI

- Docker services (Qdrant, n8n, OpenWebUI, etc.)
- Scripts sync (sync-obsidian.py, generate-indexes.py)
- Templates de base
- Documentation

## 📋 Ce qui est dans Flow-Notes-AI

- Vos notes réelles
- Vos workflows configurés
- Vos configs de production
- Vos adaptations personnelles

---

## 🎯 Avantages de cette séparation

✅ **FlowTech-AI** peut être open-source (aucune donnée perso)  
✅ **Flow-Notes-AI** reste privé (vos données)  
✅ **Updates faciles** : `git pull` dans FlowTech-AI = nouvelles features  
✅ **Sécurité** : Pas de risque de commit de données sensibles  
✅ **Fork-friendly** : Autres users clonent FlowTech-AI et créent leur propre Flow-Notes  

---

## ⚠️ Important

**NE JAMAIS** :
- Commit vos notes réelles dans Git
- Commit vos .env ou configs de prod
- Commit vos données sensibles (IPs, passwords, etc.)

**TOUJOURS** :
- Garder Notes/ en .gitignore
- Utiliser .env.example comme template
- Tester sur dev avant prod

---

**Version** : 2.0.0  
**Mise à jour** : 2025-10-18

