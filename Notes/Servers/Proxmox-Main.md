---
type: server
id: proxmox-main
name: Proxmox-Main
ip: 192.168.0.100
hostname: proxmox-t640
server_type: physical
cpu: 32
ram_gib: 128
status: active
location: homelab
created: 2024-01-01
updated: 2025-10-19
tags:
  - server
  - physical
  - proxmox
  - hypervisor
owner: flowtech
---

# Proxmox-Main - Serveur Principal

## 📋 Informations

**Hostname** : proxmox-t640  
**IP** : 192.168.0.100  
**Type** : Physical Server - Hypervisor

## 🔧 Hardware

```facts
cpu: Dual Intel Xeon (32 cores total)
ram_gib: 128
disk: 2TB NVMe + 4TB HDD
network: 1Gbps
```

## 🚀 VMs hébergées

- [[VM-DEV-246]] - Développement FlowTech-AI
- [[VM-PROD-252]] - Production FlowTech-AI
- [[VM-NEXTCLOUD-249]] - Nextcloud

## 📝 Description

Serveur physique principal hébergeant l'infrastructure FlowTech sur Proxmox VE.

## 📅 Changelog

### 2025-10-19
- 3 VMs actives
- FlowTech-AI V2 en test

### 2024-01-01
- Installation Proxmox
- Configuration initiale

