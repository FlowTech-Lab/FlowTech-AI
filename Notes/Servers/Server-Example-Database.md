---
type: server
name: Database-Server-Example
ip: 192.168.1.50
server_type: database
status: active
location: Datacenter-A
services:
  - postgresql
  - redis
  - backup-agent
created: 2025-01-10
updated: 2025-01-15
tags: [example, database, critical]
---

# Database-Server-Example

## 📋 Description

Example database server configuration.

This is a **template example** - duplicate and customize for your own servers.

## 🖧 Hardware

- **Model**: Dell PowerEdge R740
- **CPU**: 2x Intel Xeon Gold 6230 (40 cores total)
- **RAM**: 256 GB DDR4
- **Storage**: 4x 2TB NVMe SSD (RAID 10)
- **Network**: 2x 10 Gbps

## 💾 Services

### PostgreSQL Cluster

- **Version**: 15.4
- **Replication**: Primary-Replica (streaming)
- **Backup**: Daily full + hourly incrementals
- **Storage**: 2 TB

### Redis Cache

- **Version**: 7.2
- **Mode**: Cluster (3 nodes)
- **Memory**: 64 GB
- **Persistence**: AOF + RDB

## 🌐 Network

- **Primary IP**: 192.168.1.50
- **Backup IP**: 192.168.1.51
- **VLAN**: 20 (Database tier)
- **Firewall**: Only allow from app servers

## 🔐 Access

```bash
# SSH access
ssh dbadmin@192.168.1.50

# PostgreSQL access
psql -h 192.168.1.50 -U admin -d production
```

## 📊 Monitoring

- **Status**: Active ✅
- **Uptime**: 99.99%
- **Load**: 45% average
- **Last maintenance**: 2025-01-10
- **Next maintenance**: 2025-02-15

## 🔗 Related Notes

- [[PostgreSQL-Backup-Strategy]]
- [[Redis-Cluster-Config]]
- [[Database-Monitoring]]

## 📝 Notes

This is an **example server note** to demonstrate infrastructure documentation.

**To use**:
1. Copy this file
2. Rename to your server
3. Update specifications
4. Add your specific configurations

---

*Example Server - Customize for your infrastructure*

