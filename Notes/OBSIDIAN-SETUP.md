# 🔮 Obsidian Setup Guide - FlowTech-AI

Configuration complète pour utiliser Obsidian avec FlowTech-AI et synchroniser vos notes techniques avec Qdrant (RAG).

---

## 📦 Plugins Recommandés

### 🎯 Essentiels (Installation prioritaire)

| Plugin | Utilité | Configuration |
|--------|---------|---------------|
| **Templater** | Auto-insertion de templates | ✅ Obligatoire |
| **Linter** | Auto-formatage et timestamps | ✅ Obligatoire |
| **Dataview** | Requêtes et dashboards | ✅ Recommandé |
| **Obsidian Git** | Sync automatique avec Git | ⚠️ Optionnel |

### 🚀 Confort (Nice to have)

| Plugin | Utilité |
|--------|---------|
| **Commander** | Raccourcis personnalisés |
| **Quick Switcher++** | Navigation avancée |
| **Advanced Tables** | Édition de tableaux facilitée |
| **Iconize** | Icônes dans l'arborescence |
| **Auto Link Title** | Génère titres des liens |

---

## ⚙️ Configuration Linter

### Réglages de base

Ouvrez **Settings → Linter** et configurez :

#### General

```
✅ Lint on save: ON
✅ Display message on lint: ON
📝 YAML aliases section style: single-line
📝 YAML tags section style: single-line
🔤 Default escape char: "
```

#### Règles à activer (via barre de recherche)

Cherchez et activez **chacune** de ces règles :

**1. YAML Timestamp**
```
✅ Enabled
📅 Key: updated
📅 Format: yyyy-MM-dd
✅ Update only on change: ON
```

**2. YAML Key Sort**
```
✅ Enabled
📋 Order: type,id,name,ip,hostname,cpu,ram_gib,disk_gb,os,host,server_type,location,domain_type,dns_provider,ssl_enabled,ssl_expiry,services,status,created,updated,tags,owner
```

**3. Heading blank lines**
```
✅ Enabled
```

**4. Consecutive blank lines**
```
✅ Enabled
📏 Max: 1
```

**5. Remove empty sections**
```
✅ Enabled
```

**6. Remove trailing punctuation in heading**
```
✅ Enabled
```

---

### 📄 Configuration JSON (Alternative rapide)

Si vous préférez copier-coller la config :

**Fichier** : `.obsidian/plugins/obsidian-linter/data.json`

```json
{
  "general": {
    "lintOnSave": true,
    "displayMessage": true
  },
  "ruleConfigs": {
    "YAML Timestamp": {
      "enabled": true,
      "timestampKey": "updated",
      "dateFormat": "yyyy-MM-dd",
      "updateOnlyOnChange": true
    },
    "YAML Key Sort": {
      "enabled": true,
      "yamlKeysSortOrder": "type,id,name,ip,hostname,cpu,ram_gib,disk_gb,os,host,server_type,location,domain_type,dns_provider,ssl_enabled,ssl_expiry,services,status,created,updated,tags,owner"
    },
    "Heading blank lines": {
      "enabled": true
    },
    "Consecutive blank lines": {
      "enabled": true,
      "max": 1
    },
    "Remove empty sections": {
      "enabled": true
    },
    "Remove trailing punctuation in heading": {
      "enabled": true
    }
  }
}
```

---

## 🎨 Configuration Templater

### Réglages de base

Ouvrez **Settings → Templater** :

```
📁 Template folder location: _Templates
✅ Trigger Templater on new file creation: ON
✅ Enable folder templates: ON
📜 User script files folder location: _Templates/Scripts (optionnel)
```

### Folder Templates (Auto-insertion)

Ajoutez ces règles dans **Folder templates** :

| Dossier | Template |
|---------|----------|
| `VMs` | `_Templates/vm-template.md` |
| `Servers` | `_Templates/server-template.md` |
| `Domains` | `_Templates/domain-template.md` |

**Comportement** : Quand vous créez une note dans `VMs/`, le template VM s'insère automatiquement.

---

### 🔧 Templates Dynamiques (Optionnel)

Si vous voulez rendre vos templates plus interactifs, vous pouvez ajouter des prompts Templater.

**Exemple pour vm-template.md** :

```markdown
---
type: vm
id: <% tp.file.title.toLowerCase().replace(/\s+/g, '-') %>
name: <% tp.file.title %>
ip: <% tp.system.prompt("IP address?") %>
hostname: <% tp.file.title.toLowerCase() %>
cpu: <% tp.system.suggester(["2", "4", "8", "16"], ["2", "4", "8", "16"]) %>
ram_gib: <% tp.system.suggester(["4", "8", "16", "32", "64"], ["4", "8", "16", "32", "64"]) %>
disk_gb: 100
os: <% tp.system.suggester(["Ubuntu 22.04", "Ubuntu 24.04", "Debian 12", "Rocky Linux 9"], ["Ubuntu 22.04", "Ubuntu 24.04", "Debian 12", "Rocky Linux 9"]) %>
host: <% tp.system.prompt("Hypervisor host?") %>
services: []
status: active
created: <% tp.date.now("YYYY-MM-DD") %>
updated: <% tp.date.now("YYYY-MM-DD") %>
tags:
  - vm
owner: <% tp.system.prompt("Owner?", "flow") %>
---

# <% tp.file.title %>

## 📋 Informations

**VM ID** : <% tp.frontmatter.id %>  
**IP** : <% tp.frontmatter.ip %>  
**Host** : [[<% tp.frontmatter.host %>]]  

## 🔧 Configuration

```facts
cpu: <% tp.frontmatter.cpu %>
ram_gib: <% tp.frontmatter.ram_gib %>
disk_gb: <% tp.frontmatter.disk_gb %>
os: <% tp.frontmatter.os %>
```

## 🚀 Services

- Service 1
- Service 2

## 📝 Description

Description of the VM and its purpose...

## 🔗 Links

- [[<% tp.frontmatter.host %>]] - Host server

## 📅 Changelog

### <% tp.date.now("YYYY-MM-DD") %>
- VM created
```

---

## 📂 Structure de dossiers recommandée

```
Notes/
├── _Templates/           # Templates (déjà existant)
│   ├── vm-template.md
│   ├── server-template.md
│   ├── domain-template.md
│   └── Scripts/          # Scripts Templater (optionnel)
│
├── VMs/                  # Vos machines virtuelles
│   ├── VM-Web-01.md
│   └── VM-DB-01.md
│
├── Servers/              # Serveurs physiques
│   ├── Hypervisor-01.md
│   └── Prod-Server-01.md
│
├── Domains/              # Noms de domaine
│   ├── app.flowtech.ai.md
│   └── api.flowtech.ai.md
│
├── Projects/             # Projets (optionnel)
│   └── FlowTech-AI.md
│
├── MOCs/                 # Maps of Content (optionnel)
│   ├── Infrastructure-Overview.md
│   └── Services-Inventory.md
│
└── README-NOTES.md       # Documentation
```

---

## ✅ Checklist de vérification

Après configuration, testez :

### 1. Linter fonctionne
- [ ] Créez une note test
- [ ] Ajoutez du YAML désordonné
- [ ] Sauvegardez (Ctrl+S)
- [ ] Le champ `updated` doit se mettre à jour automatiquement
- [ ] Les clés YAML doivent se réorganiser

### 2. Templater fonctionne
- [ ] Créez une note dans `VMs/` (ex: "VM-Test-01")
- [ ] Le template `vm-template.md` doit s'insérer automatiquement
- [ ] Les prompts dynamiques s'affichent (si configurés)

### 3. Dataview fonctionne (si installé)
- [ ] Créez une note avec ce code :
  ````markdown
  ```dataview
  TABLE type, ip, status
  FROM "VMs" OR "Servers"
  WHERE status = "active"
  SORT name ASC
  ```
  ````
- [ ] Vous devez voir une table avec vos VMs/Servers actifs

---

## 🎯 Workflows recommandés

### Workflow 1 : Documenter une nouvelle VM

1. **Créer** : Dans `VMs/`, créez `VM-Web-03.md`
2. **Template** : Templater insère le template automatiquement
3. **Remplir** : Complétez les informations (IP, CPU, RAM, etc.)
4. **Sauvegarder** : Ctrl+S → Linter met à jour `updated:`
5. **Sync** : Le script `sync-notes.sh` synchronise vers Qdrant (toutes les heures)

### Workflow 2 : Dashboard d'infrastructure

Créez `MOCs/Infrastructure-Dashboard.md` :

````markdown
---
type: moc
name: Infrastructure Dashboard
created: 2025-10-21
updated: 2025-10-21
---

# 🏗️ Infrastructure Dashboard

## 📊 Vue d'ensemble

```dataview
TABLE
  type as "Type",
  status as "Status",
  ip as "IP"
FROM "VMs" OR "Servers" OR "Domains"
WHERE status = "active"
SORT type, name
```

## 🖥️ VMs Actives

```dataview
TABLE
  cpu as "CPU",
  ram_gib as "RAM (GB)",
  host as "Host",
  services as "Services"
FROM "VMs"
WHERE status = "active"
SORT name
```

## 🖧 Serveurs

```dataview
LIST
FROM "Servers"
WHERE status = "active"
SORT name
```

## 🌐 Domaines

```dataview
TABLE
  ip as "IP",
  ssl_enabled as "SSL",
  ssl_expiry as "Expiration SSL"
FROM "Domains"
WHERE status = "active"
SORT name
```
````

---

## 🔗 Intégration avec FlowTech-AI

### Synchronisation automatique vers Qdrant

Le script `sync-notes.sh` s'exécute automatiquement toutes les heures (configuré dans `init.sh`).

**Vérifier le statut** :
```bash
crontab -l | grep sync-notes
```

**Synchronisation manuelle** :
```bash
cd /home/flowtech/FlowTech-AI
./scripts/sync-notes.sh
```

### Accès via OpenWebUI (RAG)

1. Ouvrez http://localhost:8081
2. Créez un chat
3. Activez **"Knowledge"** → Collection `cursor-knowledge`
4. Posez des questions :
   - "Quelle est l'IP de VM-Web-01 ?"
   - "Quels services tournent sur Hypervisor-01 ?"
   - "Liste tous les domaines avec SSL actif"

---

## 🐛 Troubleshooting

### Linter ne met pas à jour `updated:`

1. Vérifiez que **Lint on save** est activé
2. Vérifiez que la règle **YAML Timestamp** est activée
3. Le champ `updated:` doit exister dans le frontmatter

### Templater ne s'insère pas

1. Vérifiez **Trigger on new file creation** = ON
2. Vérifiez que le dossier est bien mappé dans **Folder templates**
3. Créez la note dans le bon dossier (ex: `VMs/`)

### Dataview ne fonctionne pas

1. Vérifiez que le plugin Dataview est installé et activé
2. Activez **Settings → Dataview → Enable JavaScript Queries**
3. Vérifiez la syntaxe (3 backticks + `dataview`)

---

## 📚 Ressources

- [Documentation Templater](https://silentvoid13.github.io/Templater/)
- [Documentation Linter](https://github.com/platers/obsidian-linter)
- [Documentation Dataview](https://blacksmithgu.github.io/obsidian-dataview/)
- [FlowTech-AI Repository](https://github.com/your-org/FlowTech-AI)

---

**Configuration terminée ! 🎉**

Vos notes sont maintenant synchronisées automatiquement avec Qdrant et accessibles via OpenWebUI avec RAG.


