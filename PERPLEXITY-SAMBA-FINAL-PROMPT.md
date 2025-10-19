# 🚨 PROMPT PERPLEXITY - SAMBA SERVERCONTAINERS CONFIGURATION FINALE

## 📋 CONTEXTE TECHNIQUE

**Problème** : `servercontainers/samba` ne crée pas le partage `notes` malgré une configuration apparemment correcte.

### ✅ CE QUI FONCTIONNE :
- **Serveur visible** : `DEV-FLOWTECH-LAB` apparaît dans l'explorateur réseau Windows ✅
- **WS-Discovery** : Fonctionne (serveur détecté automatiquement) ✅
- **Network host** : Conteneur utilise l'interface réseau de l'hôte ✅
- **Connexion réseau** : Port 445 accessible depuis Windows ✅

### ❌ PROBLÈME :
- **Partage `notes` inexistant** : `smbclient -L localhost` ne montre que `IPC$`
- **Configuration ignorée** : Variable `SAMBA_SHARES` non prise en compte

### 🔧 CONFIGURATION ACTUELLE :

**Docker Compose** :
```yaml
samba:
  image: ghcr.io/servercontainers/samba:latest
  container_name: samba-notes
  restart: unless-stopped
  profiles: [samba]
  network_mode: host
  environment:
    - TZ=Europe/Paris
    - SAMBA_WORKGROUP=WORKGROUP
    - SAMBA_USERS=admin:HdviwuBXcmx/C5RLgnmjFTATclRyn+zY
    - SAMBA_SHARES=notes;/shares/notes;yes;no;no;admin;none;none;FlowTech Notes Share
  volumes:
    - ./Notes:/shares/notes:rw
```

**Test serveur** :
```bash
# Partages disponibles (PROBLÈME)
docker compose exec samba smbclient -L localhost -U admin
# Résultat: Seulement IPC$ - pas de partage "notes"

# Variables d'environnement (OK)
docker compose exec samba env | grep SAMBA
# SAMBA_SHARES=notes;/shares/notes;yes;no;no;admin;none;none;FlowTech Notes Share

# Configuration Samba (PROBLÈME)
docker compose exec samba cat /etc/samba/smb.conf
# Pas de section [notes] dans le fichier généré
```

### 🔍 DIAGNOSTIC WINDOWS POWERSHELL :

```powershell
# Connexion réseau OK
Test-NetConnection -ComputerName "192.168.0.246" -Port 445
# TcpTestSucceeded : True ✅

# Partages (PROBLÈME)
Get-SmbShare -ComputerName "192.168.0.246"
# Erreur: Impossible de trouver un paramètre correspondant au nom « ComputerName »

# Accès partage (PROBLÈME)
Get-ChildItem "\\192.168.0.246\notes"
# Erreur: Impossible de trouver le chemin d'accès « \\192.168.0.246\notes »
```

## 🎯 QUESTIONS SPÉCIFIQUES :

1. **Pourquoi `servercontainers/samba` ignore-t-il la variable `SAMBA_SHARES` ?**

2. **Quelle est la syntaxe EXACTE pour `servercontainers/samba` pour créer des partages ?**

3. **Comment forcer la création du partage avec `servercontainers/samba` ?**

4. **Alternative : Comment ajouter wsdd (WS-Discovery) à `dperson/samba` avec network host ?**

5. **Configuration smb.conf personnalisée avec `servercontainers/samba` - pourquoi l'authentification échoue ?**

## 💡 SOLUTIONS À EXPLORER :

### **Option A : Corriger `servercontainers/samba`**
- Syntaxe `SAMBA_SHARES` correcte
- Variables d'environnement manquantes
- Ordre de démarrage des services

### **Option B : `dperson/samba` + wsdd sidecar**
```yaml
samba:
  image: dperson/samba
  network_mode: host
  # Configuration dperson/samba

wsdd:
  image: ghcr.io/christgau/wsdd:latest
  network_mode: host
  environment:
    - WSDD_WORKGROUP=WORKGROUP
    - WSDD_NETBIOS_NAME=FLOW-SAMBA
```

### **Option C : Configuration manuelle smb.conf**
- Monter un fichier smb.conf personnalisé
- Gérer l'authentification correctement
- WS-Discovery intégré

## 🔧 ENVIRONNEMENT :

- **OS serveur** : Linux Ubuntu (VM)
- **IP serveur** : 192.168.0.246
- **OS client** : Windows 11
- **Docker** : Compose avec network_mode: host
- **Objectif** : Partage `notes` visible dans l'explorateur Windows avec WS-Discovery

## 🚨 URGENT :

**Besoin d'une solution qui fonctionne pour que l'utilisateur lambda puisse :**
1. **Voir le serveur** dans l'explorateur réseau Windows ✅ (déjà fait)
2. **Accéder au partage `notes`** avec le contenu des fichiers ❌ (à corriger)
3. **Utiliser avec Obsidian** pour les templates et notes

**Le serveur est détecté, la connexion établie, mais le partage n'existe pas.**

---

**Solution complète avec la syntaxe correcte pour `servercontainers/samba` ou alternative fonctionnelle.**
