# 📁 Samba Share - Configuration Automatique

## 🎯 Fonctionnement

### À l'installation (init.sh)

```bash
./init.sh
```

**Le script génère automatiquement** :
- ✅ User : `admin`
- ✅ Password : Généré aléatoirement (24 caractères)
- ✅ Sauvegardé dans `.env`
- ✅ Affiché à la fin de l'init

**Résultat dans .env** :
```bash
SAMBA_USER=admin
SAMBA_PASSWORD=Xk9mP2wR...  # 24 caractères aléatoires
SAMBA_UID=1000
SAMBA_GID=1000
SAMBA_PORT=445
```

### Démarrage automatique

Si `SAMBA_PASSWORD` existe dans `.env` :
- ✅ Service démarré automatiquement
- ✅ Profil `samba` activé
- ✅ Port 445 exposé

Si `SAMBA_PASSWORD` absent :
- ⏭️ Service Samba non démarré (sécurité)

---

## 🔑 Récupérer les credentials

### Dans le terminal (fin de l'init)

```
🔑 Default Credentials:
  • Langfuse: admin@flowtech.local / xxx
  • N8N: admin / xxx
  • N8N Bearer Token: xxx
  • Samba Share: admin / Xk9mP2wR...  ← ICI
    → Access: \\SERVER_IP\notes (Windows)
```

### Dans le fichier .env

```bash
# Voir le mot de passe Samba
cat .env | grep SAMBA_PASSWORD
```

---

## 🖥️ Utilisation

### Windows

```
1. Explorateur → \\192.168.x.x\notes
2. Credentials :
   User : admin
   Password : (celui dans .env)
3. ✅ Accès aux notes !
```

### Linux

```bash
sudo mount -t cifs \
  -o username=admin,password=YOUR_PASSWORD_FROM_ENV \
  //192.168.x.x/notes \
  /mnt/flowtech-notes
```

### Obsidian

```
1. Monter le partage réseau (Windows/Linux/Mac)
2. Obsidian → Open folder as vault
3. Sélectionner le dossier réseau
4. ✅ Éditer directement !
```

---

## 🔒 Sécurité

### Par défaut

✅ **User admin** : Un seul utilisateur autorisé  
✅ **Password fort** : 24 caractères aléatoires  
✅ **Pas de guest** : Authentification obligatoire  
✅ **LAN uniquement** : Pas exposé sur Internet  

### Recommandations firewall

```bash
# Autoriser seulement depuis le LAN
sudo ufw allow from 192.168.0.0/16 to any port 445

# Ou depuis une IP spécifique
sudo ufw allow from 192.168.1.100 to any port 445
```

---

## 🔧 Gestion

### Changer le mot de passe

```bash
# 1. Générer nouveau mot de passe
NEW_PASS=$(openssl rand -base64 24)

# 2. Mettre à jour .env
sed -i "s/SAMBA_PASSWORD=.*/SAMBA_PASSWORD=$NEW_PASS/" .env

# 3. Redémarrer Samba
docker compose --profile samba restart samba

# 4. Utiliser le nouveau mot de passe
echo "Nouveau password : $NEW_PASS"
```

### Désactiver Samba

```bash
# Arrêter le service
docker compose stop samba

# Ou supprimer les variables du .env
sed -i '/SAMBA_/d' .env
```

### Réactiver Samba

```bash
# Ajouter dans .env
SAMBA_USER=admin
SAMBA_PASSWORD=$(openssl rand -base64 24)
SAMBA_UID=1000
SAMBA_GID=1000
SAMBA_PORT=445

# Démarrer
docker compose --profile samba up -d samba
```

---

## 🆚 Comparaison : Samba vs Nextcloud vs Local

| Méthode | Setup | Sécurité | Vitesse | Multi-user | Externe |
|---------|-------|----------|---------|------------|---------|
| **Samba** | ⚡ Simple | 🔒 LAN only | 🚀 Rapide | ✅ Oui | ❌ Non |
| **Nextcloud** | 😰 Complexe | 🔐 SSL + Auth | 🐌 Moyen | ✅ Oui | ✅ Oui |
| **Local** | ⚡ Direct | 🔒 Machine only | 🚀 Instant | ❌ Non | ❌ Non |

**Recommandation pour vous** : **Samba** (simple, sécurisé, rapide sur LAN)

---

## 📝 Exemple complet

### Installation

```bash
git clone https://github.com/FlowTech-Lab/FlowTech-AI.git
cd FlowTech-AI
./init.sh

# Samba activé automatiquement !
# Credentials dans .env
```

### Montage Windows

```
\\192.168.1.20\notes
User : admin
Password : Xk9mP2wR...  (depuis .env)
```

### Obsidian

```
Open folder as vault
→ Z:\  (lecteur réseau monté)
→ Éditer vos notes
→ Sync automatique vers Qdrant (10 min)
```

---

**Version** : 2.0.0  
**Mise à jour** : 2025-10-18

