---
type: vm
id: vm-dev-246
name: VM-DEV-246
ip: 192.168.0.246
hostname: flowtech-dev
cpu: 16
ram_gib: 64
disk_gb: 500
os: Ubuntu 22.04
host: proxmox-main
services:
  - docker
  - flowtech-ai-dev
  - testing
status: active
created: 2025-10-18
updated: 2025-10-19
tags:
  - vm
  - dev
  - docker
  - flowtech-ai
owner: flowtech
---

# VM-DEV-246 - Développement FlowTech-AI

## 📋 Informations

**VM ID** : vm-dev-246  
**IP** : 192.168.0.246  
**Host** : Proxmox Main Server  
**Environnement** : Développement

## 🔧 Configuration

```facts
cpu: 16 cores
ram_gib: 64
disk_gb: 500
os: Ubuntu 22.04 LTS
docker_version: 24.0+
```

## 🚀 Services

- **Docker** : Container runtime
- **FlowTech-AI Dev Stack** : Environnement de test
  - OpenWebUI
  - MCP-Qdrant
  - Qdrant vector DB
  - n8n automation
  - PostgreSQL
  - Redis

## 📝 Description

VM de développement pour FlowTech-AI V2. Utilisée pour tester les nouvelles fonctionnalités avant déploiement en production.

## 🔗 Liens

- [[VM-PROD-252]] - VM de production
- [[Proxmox-Main]] - Serveur host

## 📅 Changelog

### 2025-10-19
- Stack V2 déployée
- Samba Share ajouté
- Tests sync notes → RAG

### 2025-10-18
- Migration V2 commencée
- MCP-Qdrant optimisé avec Dockerfile

