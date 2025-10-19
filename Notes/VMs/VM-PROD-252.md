---
type: vm
id: vm-prod-252
name: VM-PROD-252
ip: 192.168.0.252
hostname: flowtech-prod
cpu: 32
ram_gib: 128
disk_gb: 1000
os: Ubuntu 22.04
host: proxmox-main
services:
  - docker
  - flowtech-ai-prod
  - n8n-prod
  - qdrant-prod
status: active
created: 2025-09-01
updated: 2025-10-19
tags:
  - vm
  - production
  - docker
  - flowtech-ai
owner: flowtech
---

# VM-PROD-252 - Production FlowTech-AI

## 📋 Informations

**VM ID** : vm-prod-252  
**IP** : 192.168.0.252  
**Host** : Proxmox Main Server  
**Environnement** : **PRODUCTION**

## 🔧 Configuration

```facts
cpu: 32 cores
ram_gib: 128
disk_gb: 1TB NVMe
os: Ubuntu 22.04 LTS
docker_version: 24.0+
```

## 🚀 Services en Production

- **FlowTech-AI Stack** :
  - OpenWebUI (8081)
  - MCP-Qdrant (8000) - Cursor integration
  - Qdrant (6333) - Vector database
  - n8n (5678) - Automation
  - PostgreSQL - Données
  - Redis - Cache

## 📝 Description

VM de production FlowTech-AI. Héberge tous les services IA en production avec haute disponibilité.

## 🔒 Sécurité

- Firewall configuré (UFW)
- SSL via reverse proxy
- Backup quotidien
- Monitoring actif

## 🔗 Liens

- [[VM-DEV-246]] - VM de développement
- [[Proxmox-Main]] - Serveur host

## 📅 Changelog

### 2025-10-19
- En attente migration V2
- Backup effectué

### 2025-09-01
- VM créée
- Stack FlowTech-AI V1 déployée

