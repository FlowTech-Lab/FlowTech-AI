---
type: vm
name: WebServer-Example
ip: 192.168.1.100
ram_gib: 8
cpu: 4
disk_gb: 100
status: active
hypervisor: Proxmox-01
services:
  - nginx
  - docker
  - postgresql
created: 2025-01-15
updated: 2025-01-15
tags: [example, web, production]
---

# WebServer-Example

## 📋 Description

Example web server VM configuration for documentation purposes.

This is a **template example** - duplicate and customize for your own servers.

## 🖥️ Specifications

- **vCPU**: 4 cores
- **RAM**: 8 GB
- **Storage**: 100 GB SSD
- **OS**: Ubuntu 22.04 LTS
- **Network**: VLAN 10 (Production)

## 🔧 Configuration

### Installed Services

1. **Nginx** (Reverse Proxy)
   - Port: 80, 443
   - Config: `/etc/nginx/sites-available/`
   - SSL: Let's Encrypt

2. **Docker** (Container Runtime)
   - Version: 24.0.7
   - Compose: 2.23.0
   - Network: bridge

3. **PostgreSQL** (Database)
   - Version: 15.4
   - Port: 5432
   - Backup: Daily at 2 AM

## 🌐 Network

- **Primary IP**: 192.168.1.100
- **Gateway**: 192.168.1.1
- **DNS**: 8.8.8.8, 1.1.1.1
- **Firewall**: UFW enabled

## 🔐 Access

```bash
# SSH access
ssh admin@192.168.1.100

# Root access
sudo -i
```

## 📊 Monitoring

- **Status**: Active ✅
- **Uptime**: 99.9%
- **Last update**: 2025-01-15
- **Next maintenance**: 2025-02-01

## 🔗 Related Notes

- [[Proxmox-01]] - Hypervisor
- [[PostgreSQL-DB-Server]] - Database configuration
- [[Nginx-Config]] - Web server setup

## 📝 Notes

This is an **example note** to show you how to document your infrastructure.

**To use this template**:
1. Duplicate this file
2. Rename to your VM name (e.g., `VM-MyWebServer-01.md`)
3. Update all fields in frontmatter
4. Customize content sections
5. Save and let Obsidian link everything!

---

*Example VM - Feel free to delete or modify*

# Test Note Update
This is a test modification for sync detection.
