# 🚀 FlowTech-AI Deployment Guide

## Production Deployment Strategy

### Infrastructure Requirements

#### Minimum Specifications
- **CPU**: 8 cores (Intel/AMD x64)
- **RAM**: 32GB (recommended 64GB)
- **Storage**: 100GB SSD (recommended NVMe)
- **Network**: 1Gbps connection
- **GPU**: NVIDIA RTX 4070 Super (optional)

#### Recommended Setup
- **Proxmox VE**: Hypervisor platform
- **VM Configuration**: 
  - 16 vCPUs
  - 64GB RAM
  - 200GB NVMe storage
  - GPU passthrough for Ollama

### Environment Configuration

#### Production Environment
```bash
# Production .env
NODE_ENV=production
POSTGRES_PASSWORD=<strong-password>
LANGFUSE_INIT_USER_PASSWORD=<strong-password>
N8N_BASIC_AUTH_PASSWORD=<strong-password>
MINIO_ROOT_PASSWORD=<strong-password>
CLICKHOUSE_PASSWORD=<strong-password>
REDIS_AUTH=<strong-password>

# Security
N8N_SECURITY_API_BEARER_AUTH=<64-char-token>
LANGFUSE_NEXTAUTH_SECRET=<32-char-secret>
LANGFUSE_SALT=<16-char-salt>
LANGFUSE_ENCRYPTION_KEY=<32-char-key>
```

#### Network Security
```bash
# Firewall rules (ufw)
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP (reverse proxy)
ufw allow 443/tcp   # HTTPS (reverse proxy)
ufw deny 8081/tcp   # Block direct OpenWebUI access
ufw deny 5678/tcp   # Block direct n8n access
ufw deny 3300/tcp   # Block direct Langfuse access
```

### Reverse Proxy Configuration

#### Nginx Configuration
```nginx
# /etc/nginx/sites-available/flowtech-ai
server {
    listen 80;
    server_name ai.flowtech.local;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name ai.flowtech.local;
    
    ssl_certificate /etc/ssl/certs/flowtech-ai.crt;
    ssl_certificate_key /etc/ssl/private/flowtech-ai.key;
    
    # OpenWebUI
    location / {
        proxy_pass http://localhost:8081;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # n8n
    location /n8n/ {
        proxy_pass http://localhost:5678/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Langfuse
    location /langfuse/ {
        proxy_pass http://localhost:3300/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Backup Strategy

#### Automated Backups
```bash
#!/bin/bash
# /opt/flowtech-ai/backup.sh

BACKUP_DIR="/opt/backups/flowtech-ai"
DATE=$(date +%Y%m%d_%H%M%S)
CONTAINER_NAME="flowtech-ai"

# Create backup directory
mkdir -p "$BACKUP_DIR/$DATE"

# Backup PostgreSQL
docker compose exec -T postgres pg_dump -U n8n n8n > "$BACKUP_DIR/$DATE/postgres.sql"

# Backup Qdrant
docker compose exec qdrant tar -czf - /qdrant/storage > "$BACKUP_DIR/$DATE/qdrant.tar.gz"

# Backup AI_Data
tar -czf "$BACKUP_DIR/$DATE/ai_data.tar.gz" AI_Data/

# Backup configuration
cp .env "$BACKUP_DIR/$DATE/"
cp docker-compose.yml "$BACKUP_DIR/$DATE/"

# Cleanup old backups (keep 30 days)
find "$BACKUP_DIR" -type d -mtime +30 -exec rm -rf {} \;
```

#### Cron Job
```bash
# Add to crontab
0 2 * * * /opt/flowtech-ai/backup.sh
```

### Monitoring Setup

#### Prometheus Configuration
```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'flowtech-ai'
    static_configs:
      - targets:
        - 'localhost:8081'  # OpenWebUI
        - 'localhost:5678'  # n8n
        - 'localhost:3300'  # Langfuse
        - 'localhost:6333'  # Qdrant
```

#### Grafana Dashboards
- **Service Health**: Uptime and response times
- **Resource Usage**: CPU, RAM, disk, network
- **AI Metrics**: Model performance, token usage
- **Database Metrics**: Query performance, connections

### Scaling Considerations

#### Vertical Scaling
```bash
# Increase VM resources in Proxmox
# Update docker-compose.yml with resource limits
services:
  openwebui:
    deploy:
      resources:
        limits:
          memory: 8G
          cpus: '4'
```

#### Horizontal Scaling
```yaml
# docker-compose.scale.yml
services:
  openwebui:
    deploy:
      replicas: 2
    ports:
      - "8081-8082:8080"
```

### Security Hardening

#### Container Security
```yaml
# Security configurations in docker-compose.yml
services:
  postgres:
    security_opt:
      - no-new-privileges:true
    read_only: true
    tmpfs:
      - /tmp:noexec,nosuid,size=100m
```

#### Network Isolation
```yaml
# Custom network with restricted access
networks:
  flow-ai-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
```

### Disaster Recovery

#### Recovery Procedures
1. **Service Recovery**:
   ```bash
   docker compose down
   docker compose up -d
   ```

2. **Data Recovery**:
   ```bash
   # Restore from backup
   tar -xzf backup/ai_data.tar.gz
   docker compose exec -T postgres psql -U n8n n8n < backup/postgres.sql
   ```

3. **Full System Recovery**:
   - Deploy new VM from template
   - Restore configuration files
   - Restore data from backups
   - Verify service functionality

### Maintenance Procedures

#### Regular Maintenance
- **Weekly**: Review logs, check disk space
- **Monthly**: Update dependencies, security patches
- **Quarterly**: Full backup restoration test
- **Annually**: Security audit, capacity planning

#### Update Procedures
```bash
# Update services
docker compose pull
docker compose up -d

# Verify updates
docker compose ps
./scripts/health-check.sh
```

---

**Related**: [MONITORING.md](MONITORING.md) | [SECURITY.md](SECURITY.md)
