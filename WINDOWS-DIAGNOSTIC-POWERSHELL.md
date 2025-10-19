# 🔍 DIAGNOSTIC WINDOWS POWERSHELL - SAMBA PARTAGE VIDE

## 📋 COMMANDES POWERSHELL À EXÉCUTER SUR WINDOWS

### 🔍 1. Test de connectivité réseau

```powershell
# Test ping vers le serveur
Test-NetConnection -ComputerName "192.168.0.246" -Port 445

# Test ping vers le serveur
ping 192.168.0.246

# Vérifier la résolution DNS/NetBIOS
nslookup dev-flowtech-lab
nslookup 192.168.0.246
```

### 🔍 2. Test d'accès SMB direct

```powershell
# Lister les partages disponibles sur le serveur
Get-SmbShare -ComputerName "192.168.0.246"

# Tester l'accès au partage spécifique
Test-Path "\\192.168.0.246\notes"

# Lister le contenu du partage
Get-ChildItem "\\192.168.0.246\notes"

# Test avec credentials explicites
$cred = Get-Credential -UserName "admin" -Message "Enter password"
Get-ChildItem "\\192.168.0.246\notes" -Credential $cred
```

### 🔍 3. Diagnostic des services Windows

```powershell
# Vérifier les services de découverte réseau
Get-Service -Name "*Browser*"
Get-Service -Name "*LanmanServer*"
Get-Service -Name "*LanmanWorkstation*"

# Vérifier le statut des services
Get-Service | Where-Object {$_.Name -like "*SMB*" -or $_.Name -like "*Lanman*"}
```

### 🔍 4. Test de découverte réseau

```powershell
# Forcer la découverte réseau
net view \\192.168.0.246

# Lister les machines du groupe de travail
net view /domain:WORKGROUP

# Tester la résolution NetBIOS
nbtstat -A 192.168.0.246
```

### 🔍 5. Diagnostic des permissions

```powershell
# Vérifier les permissions sur le partage
Get-SmbShareAccess -ComputerName "192.168.0.246" -Name "notes"

# Test d'authentification
net use \\192.168.0.246\notes /user:admin

# Vérifier les connexions réseau actives
net use
```

### 🔍 6. Test WS-Discovery (Windows 11)

```powershell
# Vérifier si WS-Discovery fonctionne
Get-WSManInstance -ResourceURI winrm/config/client -Enumerate

# Test avec PowerShell avancé
$discovery = New-Object System.ServiceModel.Discovery.UdpDiscoveryEndpoint
# (nécessite .NET Framework)
```

### 🔍 7. Diagnostic pare-feu Windows

```powershell
# Vérifier les règles de pare-feu
Get-NetFirewallRule | Where-Object {$_.DisplayName -like "*SMB*" -or $_.DisplayName -like "*File*"}

# Vérifier les règles de pare-feu pour SMB
netsh advfirewall firewall show rule name="File and Printer Sharing (SMB-In)"
```

### 🔍 8. Test complet avec logging

```powershell
# Activer le logging SMB (nécessite admin)
# Dans Event Viewer: Applications and Services Logs > Microsoft > Windows > SMBClient

# Test avec verbose
Get-ChildItem "\\192.168.0.246\notes" -Verbose -Force

# Test avec debug
net use \\192.168.0.246\notes /persistent:yes /user:admin
```

---

## 🎯 RÉSULTATS ATTENDUS vs PROBLÈMES

### ✅ Si tout fonctionne :
- `Test-NetConnection` : Success
- `Get-SmbShare` : Liste le partage "notes"
- `Get-ChildItem` : Montre les dossiers (_Templates, VMs, etc.)

### ❌ Problèmes possibles :
1. **Authentication failed** : Problème de credentials
2. **Access denied** : Problème de permissions
3. **Network path not found** : Problème de réseau
4. **Empty directory** : Problème de configuration Samba

---

## 📋 RAPPORT À FAIRE

Après avoir exécuté ces commandes, note :

1. **Quelles commandes réussissent ?**
2. **Quelles commandes échouent ?**
3. **Messages d'erreur exacts**
4. **Contenu retourné par `Get-ChildItem`**

---

## 🔧 COMMANDES DE RÉPARATION POSSIBLES

```powershell
# Réinitialiser les connexions réseau
net use * /delete
net use \\192.168.0.246\notes /user:admin

# Forcer la découverte
ipconfig /flushdns
ipconfig /registerdns

# Redémarrer les services
Restart-Service LanmanWorkstation
Restart-Service LanmanServer
```

---

**Exécute ces commandes et donne-moi les résultats !** 🚀
