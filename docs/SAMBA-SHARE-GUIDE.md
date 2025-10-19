# 📁 Samba Share - Guide d'utilisation

Partage réseau des notes FlowTech-AI accessible depuis Windows/Linux/Mac

---

## 🎯 Qu'est-ce que c'est ?

Un **partage réseau SMB/CIFS** qui permet d'accéder au dossier `Notes/` depuis n'importe quel appareil sur votre réseau local, **sans Nextcloud**.

### Avantages

✅ **Windows natif** : Montage réseau `\\IP\notes`  
✅ **Linux compatible** : Mount CIFS  
✅ **Obsidian direct** : Ouvre le vault réseau  
✅ **Temps réel** : Modifications instantanées  
✅ **Pas de sync** : Travail direct sur le serveur  
✅ **Multi-utilisateurs** : Plusieurs personnes peuvent éditer  

---

## ⚙️ Configuration

### Variables dans .env

```bash
# Samba Share (optionnel)
SAMBA_USER=your-username
SAMBA_PASSWORD=your-secure-password
SAMBA_UID=1000           # User ID Linux
SAMBA_GID=1000           # Group ID Linux
SAMBA_PORT=445           # Port SMB (445 par défaut)
```

### Activer le service

```bash
# Le service est déjà dans docker-compose.yml
docker compose up -d samba
```

---

## 🖥️ Montage depuis Windows

### Option 1 : Interface graphique

1. Ouvrir **Explorateur Windows**
2. Dans la barre d'adresse, taper :
   ```
   \\192.168.1.20\notes
   ```
   _(Remplacer par l'IP de votre serveur)_

3. Entrer les credentials :
   - **Utilisateur** : `your-username` (défini dans .env)
   - **Mot de passe** : `your-secure-password`

4. ✅ Le dossier s'ouvre !

### Option 2 : Montage permanent (lecteur réseau)

```cmd
# PowerShell (Admin)
net use Z: \\192.168.1.20\notes /user:your-username your-password /persistent:yes
```

**Résultat** : Lecteur `Z:` permanent avec vos notes

### Option 3 : Obsidian sur Windows

1. Monter le partage réseau (Option 1 ou 2)
2. Ouvrir Obsidian
3. **Open folder as vault** → `Z:\` ou `\\192.168.1.20\notes`
4. ✅ Éditer directement vos notes !

---

## 🐧 Montage depuis Linux

### Installer CIFS utils

```bash
# Ubuntu/Debian
sudo apt install cifs-utils

# Fedora/RHEL
sudo dnf install cifs-utils
```

### Montage manuel

```bash
sudo mkdir -p /mnt/flowtech-notes

sudo mount -t cifs \
  -o username=your-username,password=your-password,uid=1000,gid=1000 \
  //192.168.1.20/notes \
  /mnt/flowtech-notes
```

### Montage permanent (/etc/fstab)

```bash
# Créer fichier credentials
sudo nano /root/.smbcredentials

# Contenu :
username=your-username
password=your-password

# Permissions
sudo chmod 600 /root/.smbcredentials

# Ajouter dans /etc/fstab
//192.168.1.20/notes  /mnt/flowtech-notes  cifs  credentials=/root/.smbcredentials,uid=1000,gid=1000,file_mode=0755,dir_mode=0755  0  0

# Monter
sudo mount -a
```

### Obsidian sur Linux

```bash
# Monter le partage
sudo mount //192.168.1.20/notes /mnt/flowtech-notes

# Ouvrir Obsidian
obsidian /mnt/flowtech-notes
```

---

## 🍎 Montage depuis macOS

### Finder

1. **Finder** → **Go** → **Connect to Server** (⌘K)
2. Adresse : `smb://192.168.1.20/notes`
3. Credentials :
   - Utilisateur : `your-username`
   - Mot de passe : `your-password`
4. ✅ Le partage s'ouvre dans Finder

### Terminal

```bash
# Créer point de montage
mkdir -p ~/flowtech-notes

# Monter
mount -t smbfs //your-username:your-password@192.168.1.20/notes ~/flowtech-notes
```

---

## 🔒 Sécurité

### Firewall

```bash
# Autoriser port 445 uniquement depuis LAN
sudo ufw allow from 192.168.1.0/24 to any port 445
```

### Credentials

⚠️ **NE JAMAIS** utiliser `changeme` en production !

```bash
# Générer mot de passe fort
openssl rand -base64 32

# Dans .env
SAMBA_PASSWORD=votre-mot-de-passe-fort
```

### Permissions

Le service Samba utilise les UID/GID configurés :
- `SAMBA_UID=1000` (votre user Linux)
- `SAMBA_GID=1000` (votre groupe Linux)

→ Les fichiers créés depuis Windows auront les bonnes permissions sur Linux

---

## 🔄 Workflow avec Samba

### Setup initial

```bash
# 1. Configurer .env
SAMBA_USER=flowtech
SAMBA_PASSWORD=$(openssl rand -base64 24)

# 2. Démarrer Samba
docker compose up -d samba

# 3. Windows : Monter \\SERVER_IP\notes
# 4. Obsidian : Ouvrir vault réseau
```

### Utilisation quotidienne

```
Windows/Linux/Mac (Obsidian)
  ↓ Édition directe sur \\SERVER_IP\notes
Fichiers modifiés instantanément
  ↓ Détection par sync-obsidian.py (cron 10 min)
Update Qdrant RAG
  ↓ Interrogation via OpenWebUI/Cursor
```

---

## 🆚 Samba vs Nextcloud

| Critère | Samba | Nextcloud |
|---------|-------|-----------|
| **Setup** | ✅ Simple (1 service) | 😰 Complexe (app + config) |
| **Performance** | ✅ Rapide (direct) | 😰 Overhead HTTP |
| **Windows** | ✅ Natif | 😰 Client requis |
| **Mobile** | ❌ Non | ✅ Apps mobiles |
| **Web** | ❌ Non | ✅ Interface web |
| **Versioning** | ❌ Non | ✅ Oui |
| **Partage externe** | ❌ LAN uniquement | ✅ Internet |

**Recommandation** :
- **Usage local uniquement** → Samba ✅ (plus simple)
- **Besoin mobile/web/externe** → Nextcloud

---

## 🧪 Test

### Vérifier que Samba fonctionne

```bash
# Depuis le serveur
docker compose logs samba

# Tester connexion
smbclient -L localhost -U your-username
# Enter password: ****
# Devrait lister le partage "notes"
```

### Depuis Windows

```cmd
# Test connexion
net use \\192.168.1.20\notes /user:your-username
# Mot de passe : ****
# ✅ Si succès : "The command completed successfully"
```

### Depuis Linux

```bash
# Liste les partages
smbclient -L 192.168.1.20 -U your-username
# Enter password: ****

# Test montage
sudo mount -t cifs -o username=your-username //192.168.1.20/notes /mnt/test
```

---

## 🛠️ Troubleshooting

### Port 445 déjà utilisé (Windows)

Si le port 445 est utilisé localement par Windows :

```yaml
# docker-compose.yml - utiliser autre port
ports:
  - "4445:445"  # Utiliser 4445 au lieu de 445
```

**Montage** :
```
\\192.168.1.20:4445\notes
```

### Permissions denied

```bash
# Vérifier UID/GID
id

# Ajuster dans .env
SAMBA_UID=1000  # Votre UID
SAMBA_GID=1000  # Votre GID

# Redémarrer
docker compose restart samba
```

### Obsidian vault lent

Si le vault réseau est lent :
- Utiliser cache/indexing Obsidian
- Ou sync local (rsync/Syncthing) puis édition locale

---

## 📝 Configuration recommandée .env

```bash
# Samba Network Share (optionnel - pour accès réseau local)
SAMBA_ENABLED=true
SAMBA_USER=flowtech
SAMBA_PASSWORD=your-secure-password-here
SAMBA_UID=1000
SAMBA_GID=1000
SAMBA_PORT=445

# Si port 445 conflit (Windows), utiliser 4445
# SAMBA_PORT=4445
```

---

## 🎯 Use Cases

### 1. Développeur solo (LAN uniquement)

```
✅ Utiliser Samba
- Simple
- Rapide
- Pas besoin de Nextcloud
```

### 2. Équipe/Multi-sites

```
✅ Utiliser Nextcloud
- Accès web
- Sync multi-devices
- Apps mobiles
- Partage externe
```

### 3. Hybride

```
✅ Les deux !
- Samba pour édition locale rapide
- Nextcloud pour sync externe/mobile
```

---

**Version** : 1.0.0  
**Mise à jour** : 2025-10-18

