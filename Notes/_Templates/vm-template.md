---
type: vm
id: vm-001-example
name: VM-001-Example
ip: 192.168.1.100
hostname: vm-001-example
cpu: 4
ram_gib: 8
disk_gb: 100
os: Ubuntu 22.04
host: hypervisor-01
services:
  - docker
  - app-service
status: active
created: 2025-01-01
updated: 2025-01-01
tags:
  - vm
  - example
  - docker
owner: your-name
---

# VM-001-Example

## 📋 Informations

**VM ID** : vm-001-example  
**IP** : 192.168.1.100  
**Host** : [[Hypervisor-01]]  

## 🔧 Configuration

```facts
cpu: 4
ram_gib: 8
disk_gb: 100
os: Ubuntu 22.04
```

## 🚀 Services

- **Docker** : Container runtime
- **App-Service** : Your application service

## 📝 Description

Description of the VM and its purpose...

## 🔗 Links

- [[Hypervisor-01]] - Host server
- [[Docker]] - Technology used

## 📅 Changelog

### 2025-10-18
- VM créée
- Services installés

