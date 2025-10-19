# 🚨 PROMPT PERPLEXITY - SAMBA URGENT - PARTAGE INVISIBLE

## 📋 SITUATION ACTUELLE - BLOQUÉ

**Problème** : `servercontainers/samba` ne crée pas le partage malgré toutes les tentatives de configuration.

### ✅ CE QUI FONCTIONNE :
- **Serveur visible** : `DEV-FLOWTECH-LAB` apparaît dans l'explorateur Windows ✅
- **WS-Discovery** : Fonctionne (serveur détecté automatiquement) ✅
- **Network host** : Conteneur utilise l'interface réseau de l'hôte ✅
- **Connexion réseau** : Port 445 accessible depuis Windows ✅

### ❌ PROBLÈME PERSISTANT :
- **Partage `notes` inexistant** : `smbclient -L localhost` ne montre que `IPC$`
- **Configuration ignorée** : Toutes les syntaxes tentées échouent

## 🔧 CONFIGURATIONS TENTÉES (TOUTES ÉCHOUÉES) :

### **Tentative 1 : Variables d'environnement**
```yaml
environment:
  - SAMBA_SHARES=notes;/shares/notes;yes;no;no;admin;none;none;FlowTech Notes Share
```
**Résultat** : Variable non reconnue

### **Tentative 2 : SAMBA_VOLUME_CONFIG avec syntaxe point-virgule**
```yaml
environment:
  - SAMBA_VOLUME_CONFIG_notes=[FlowTech Notes]; path=/shares/notes; valid users = admin; guest ok = no; read only = no; browseable = yes
```
**Résultat** : Configuration générée mais partage invisible

### **Tentative 3 : SAMBA_VOLUME_CONFIG avec syntaxe multiline**
```yaml
environment:
  - SAMBA_VOLUME_CONFIG_notes=|
      [FlowTech Notes]
      path = /shares/notes
      valid users = admin
      guest ok = no
      browseable = yes
      read only = no
```
**Résultat** : Erreur "Unknown parameter encountered"

### **Tentative 4 : Configuration complète avec CAP_NET_ADMIN**
```yaml
samba:
  image: ghcr.io/servercontainers/samba:latest
  network_mode: host
  cap_add:
    - CAP_NET_ADMIN
  environment:
    - TZ=Europe/Paris
    - SAMBA_CONF_LOG_LEVEL=3
    - AVAHI_DISABLE=0
    - WSDD2_DISABLE=0
    - ACCOUNT_admin=HdviwuBXcmx/C5RLgnmjFTATclRyn+zY
    - UID_admin=1000
    - SAMBA_VOLUME_CONFIG_notes=|
        [notes]
          path = /shares/notes
          read only = no
          browsable = yes
          guest ok = no
          valid users = admin
```
**Résultat** : Même erreur "Unknown parameter encountered"

### **Tentative 5 : Fichier smb.conf personnalisé**
```yaml
volumes:
  - ./samba/smb.conf:/etc/samba/smb.conf:ro
```
**Résultat** : À tester (en cours)

## 🔍 DIAGNOSTIC ACTUEL :

**Test serveur** :
```bash
# Partages disponibles
docker compose exec samba smbclient -L localhost -U admin
# Résultat: Seulement IPC$ - pas de partage "notes"

# Configuration générée
docker compose exec samba cat /etc/samba/smb.conf
# Résultat: Pas de section [notes] ou erreur de syntaxe
```

**Test Windows** :
```powershell
# Connexion réseau OK
Test-NetConnection -ComputerName "192.168.0.246" -Port 445
# TcpTestSucceeded : True ✅

# Partages (PROBLÈME)
Get-ChildItem "\\192.168.0.246\notes"
# Erreur: Impossible de trouver le chemin d'accès
```

## 🎯 QUESTIONS URGENTES :

1. **Quelle est la syntaxe EXACTE et FONCTIONNELLE pour `servercontainers/samba` ?**

2. **Comment créer un partage qui apparaît dans `smbclient -L localhost` ?**

3. **Alternative : Comment utiliser `dperson/samba` avec WS-Discovery fonctionnel ?**

4. **Configuration smb.conf personnalisée - pourquoi ça ne marche pas ?**

5. **Y a-t-il une image Docker Samba plus simple et fiable ?**

## 💡 SOLUTIONS À EXPLORER :

### **Option A : Syntaxe correcte pour servercontainers/samba**
- Documentation officielle exacte
- Exemples fonctionnels
- Variables d'environnement correctes

### **Option B : dperson/samba + wsdd sidecar**
```yaml
samba:
  image: dperson/samba
  network_mode: host
  command: >
    -s "notes;/shares/notes;yes;no;no;admin"
    -u "admin;password"
    -w "WORKGROUP"
    -S -p -n

wsdd:
  image: viniciusleterio/wsdd
  network_mode: host
```

### **Option C : Image Samba alternative**
- `samba/samba` officielle
- Configuration manuelle complète
- WS-Discovery intégré

## 🔧 ENVIRONNEMENT :

- **OS serveur** : Linux Ubuntu (VM)
- **IP serveur** : 192.168.0.246
- **OS client** : Windows 11
- **Docker** : Compose avec network_mode: host
- **Objectif** : Partage `notes` visible dans l'explorateur Windows avec WS-Discovery

## 🚨 URGENT :

**Besoin d'une solution qui FONCTIONNE pour que l'utilisateur lambda puisse :**
1. **Voir le serveur** dans l'explorateur réseau Windows ✅ (déjà fait)
2. **Accéder au partage `notes`** avec le contenu des fichiers ❌ (BLOQUÉ)
3. **Utiliser avec Obsidian** pour les templates et notes

**Le serveur est détecté, la connexion établie, mais le partage n'existe PAS.**

---

**SOLUTION COMPLÈTE ET FONCTIONNELLE REQUISE - Plus de devinettes !**
