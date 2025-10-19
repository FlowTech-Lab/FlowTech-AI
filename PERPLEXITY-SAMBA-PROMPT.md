# 🚨 PROMPT PERPLEXITY - PROBLÈME SAMBA DOCKER + WINDOWS NETWORK DISCOVERY

## 📋 CONTEXTE TECHNIQUE

**Problème** : Serveur Samba dans Docker accessible par IP directe mais **invisible** dans l'explorateur réseau Windows.

### 🔧 Configuration actuelle :

**Docker Compose (dperson/samba)** :
```yaml
samba:
  image: dperson/samba
  container_name: samba-notes
  restart: unless-stopped
  profiles: [samba]
  environment:
    - USER=admin;HdviwuBXcmx/C5RLgnmjFTATclRyn+zY
    - SHARE=notes;/notes;yes;no;no;admin;admin;admin
    - USERID=1000
    - GROUPID=1000
    - WORKGROUP=WORKGROUP
  ports:
    - "445:445"      # SMB/CIFS
    - "137:137/udp"  # NetBIOS Name Service
    - "138:138/udp"  # NetBIOS Datagram Service
    - "139:139/tcp"  # NetBIOS Session Service
  volumes:
    - ./Notes:/notes:rw
  command: >
    -s "notes;/notes;yes;no;no;admin;admin;admin"
    -u "admin;HdviwuBXcmx/C5RLgnmjFTATclRyn+zY"
    -w "WORKGROUP"
    -S -p -n
```

### ✅ CE QUI FONCTIONNE :
- **Connexion directe** : `\\192.168.0.246\notes` ✅
- **Authentification** : admin/mot de passe ✅
- **Partage accessible** : Lecture/écriture ✅
- **Services actifs** : smbd + nmbd ✅
- **Ports ouverts** : 137, 138, 139, 445 ✅

### ❌ PROBLÈME :
- **Découverte réseau Windows** : Serveur **invisible** dans l'explorateur réseau
- **NetBIOS** : Fonctionne (test nmblookup réussi)
- **Master Browser** : Samba est master browser pour WORKGROUP

### 🔍 DIAGNOSTIC DÉTAILLÉ :

**Logs Samba** :
```
Samba name server 00E64C65AAAC is now a local master browser for workgroup WORKGROUP on subnet 172.21.0.2
```

**Test NetBIOS** :
```
172.21.0.2 *<00>
Looking up status of 172.21.0.2
	2AA9F832C458    <00> -         B <ACTIVE> 
	2AA9F832C458    <03> -         B <ACTIVE> 
	2AA9F832C458    <20> -         B <ACTIVE> 
	WORKGROUP       <00> - <GROUP> B <ACTIVE> 
	WORKGROUP       <1e> - <GROUP> B <ACTIVE> 
```

**Statut conteneur** :
```
samba-notes    Up 3 minutes (healthy)    0.0.0.0:139->139/tcp, [::]:139->139/tcp, 0.0.0.0:137-138->137-138/udp, [::]:137-138->137-138/udp, 0.0.0.0:445->445/tcp, [::]:445->445/tcp
```

## 🎯 QUESTIONS SPÉCIFIQUES :

1. **Pourquoi un serveur Samba Docker avec NetBIOS actif n'apparaît-il pas dans l'explorateur réseau Windows 11 ?**

2. **Quelles sont les causes courantes de ce problème avec dperson/samba ?**

3. **Comment forcer la découverte réseau Windows pour un serveur Samba Docker ?**

4. **Quelles alternatives à dperson/samba pour une meilleure compatibilité Windows ?**

5. **Configuration smb.conf manuelle vs dperson/samba pour la visibilité réseau ?**

6. **Problèmes de réseau Docker bridge vs host networking pour Samba ?**

## 🔧 ENVIRONNEMENT :

- **OS serveur** : Linux Ubuntu (VM)
- **IP serveur** : 192.168.0.246
- **OS client** : Windows 11
- **Réseau** : LAN local
- **Docker** : Compose avec réseau bridge par défaut
- **Image** : dperson/samba (latest)

## 💡 SOLUTIONS À EXPLORER :

1. **Changer l'image Docker** (samba/samba vs dperson/samba)
2. **Configuration réseau Docker** (host networking)
3. **Configuration smb.conf manuelle** 
4. **Paramètres Windows** (découverte réseau, pare-feu)
5. **Alternative** : Lecteur réseau permanent + raccourci

**Besoin d'une solution qui permette la découverte automatique dans l'explorateur réseau Windows tout en gardant la simplicité Docker Compose.**

---

**URGENT** : Solution pour utilisateur lambda qui installe FlowTech-AI sur serveur Linux et veut accéder aux notes depuis Windows via l'explorateur réseau.
