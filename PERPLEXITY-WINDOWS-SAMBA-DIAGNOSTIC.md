# 🚨 PROMPT PERPLEXITY - DIAGNOSTIC WINDOWS SAMBA PARTAGE VIDE

## 📋 CONTEXTE TECHNIQUE

**Problème** : Serveur Samba Docker visible dans l'explorateur Windows mais **partage vide** malgré des fichiers présents côté serveur.

### ✅ CE QUI FONCTIONNE :
- **Serveur visible** : `DEV-FLOWTECH-LAB` apparaît dans l'explorateur réseau Windows
- **Connexion établie** : Accès au serveur réussi
- **WS-Discovery** : Fonctionne (serveur détecté automatiquement)

### ❌ PROBLÈME :
- **Partage vide** : Le dossier `notes` s'ouvre mais aucun contenu visible
- **Fichiers présents côté serveur** : 7 dossiers + fichiers dans `/Notes/`

### 🔧 CONFIGURATION SERVEUR :

**Docker Samba (servercontainers/samba)** :
```yaml
samba:
  image: ghcr.io/servercontainers/samba:latest
  network_mode: host
  environment:
    - SAMBA_WORKGROUP=WORKGROUP
    - SAMBA_USERS=admin:HdviwuBXcmx/C5RLgnmjFTATclRyn+zY
    - SAMBA_SHARES=notes:/shares/notes:admin:admin:755:755:yes:no:no:no:admin
  volumes:
    - ./Notes:/shares/notes:rw
```

**Contenu côté serveur** :
```
Notes/
├── _Templates/     ← Modèles Obsidian
├── VMs/           ← Exemple VM
├── Servers/       ← Exemple serveur
├── Domains/       ← Exemple domaine
├── Projects/      ← Projets
├── _Indexes/      ← Index
└── README-NOTES.md
```

**Test serveur réussi** :
```bash
docker compose exec samba ls -la /shares/notes/
# ✅ Tous les dossiers visibles
```

## 🎯 QUESTIONS SPÉCIFIQUES :

1. **Pourquoi un partage Samba Docker apparaît vide dans l'explorateur Windows alors que les fichiers sont présents côté serveur ?**

2. **Quelles sont les causes courantes de ce problème avec servercontainers/samba ?**

3. **Comment diagnostiquer avec PowerShell pourquoi `Get-ChildItem \\192.168.0.246\notes` retourne vide ?**

4. **Problèmes de permissions Unix vs Windows avec Docker volumes ?**

5. **Configuration `SAMBA_SHARES` correcte pour servercontainers/samba ?**

6. **Problèmes de UID/GID avec network_mode: host ?**

## 🔍 DIAGNOSTIC POWERSHELL À FAIRE :

```powershell
# Test de connectivité
Test-NetConnection -ComputerName "192.168.0.246" -Port 445

# Lister les partages
Get-SmbShare -ComputerName "192.168.0.246"

# Tester l'accès
Get-ChildItem "\\192.168.0.246\notes"

# Test avec credentials
$cred = Get-Credential -UserName "admin"
Get-ChildItem "\\192.168.0.246\notes" -Credential $cred
```

## 💡 SOLUTIONS À EXPLORER :

1. **Permissions Docker** : UID/GID mapping
2. **Configuration SAMBA_SHARES** : Syntaxe correcte
3. **Pare-feu Windows** : Règles SMB
4. **Services Windows** : LanmanWorkstation, Browser
5. **Authentification** : Credentials Windows vs Samba
6. **Alternative** : Changer vers dperson/samba avec config manuelle

## 🔧 ENVIRONNEMENT :

- **OS serveur** : Linux Ubuntu (VM)
- **IP serveur** : 192.168.0.246
- **OS client** : Windows 11
- **Docker** : Compose avec network_mode: host
- **Image** : ghcr.io/servercontainers/samba:latest
- **Partage** : notes → /shares/notes

## 🚨 URGENT :

**Besoin d'une solution pour que l'utilisateur lambda puisse voir le contenu du partage dans l'explorateur Windows et utiliser Obsidian avec les templates.**

**Le serveur est détecté, la connexion établie, mais le contenu invisible.**

---

**Solution complète avec diagnostic PowerShell et correction de configuration.**
