# 🔧 FlowTech-AI Troubleshooting Guide

## Common Issues and Solutions

### Service Startup Issues

#### PostgreSQL Volume Mount Error
**Error**: `change mount propagation through procfd: open o_path procfd`

**Solution**: This is resolved in the current version using Docker named volumes instead of bind mounts.

**Verification**:
```bash
docker compose logs postgres
# Should show successful startup without mount errors
```

#### Service Won't Start
**Symptoms**: Services fail to start or crash immediately

**Diagnosis**:
```bash
# Check service status
docker compose ps

# Check logs
docker compose logs [service-name]

# Check system resources
docker stats
```

**Solutions**:
1. **Insufficient resources**: Increase RAM/CPU allocation
2. **Port conflicts**: Check if ports are already in use
3. **Permission issues**: Fix AI_Data permissions

```bash
# Fix permissions
sudo chown -R $USER:$USER AI_Data/
chmod -R 755 AI_Data/
```

#### Network Connectivity Issues
**Symptoms**: Services can't communicate with each other

**Diagnosis**:
```bash
# Check network
docker network ls
docker network inspect flowtech-ai_flow-ai-network

# Test connectivity
docker compose exec openwebui ping postgres
docker compose exec n8n ping qdrant
```

**Solutions**:
1. **Restart network**: `docker compose down && docker compose up -d`
2. **Check firewall**: Ensure Docker ports are not blocked
3. **Verify DNS**: Use container names, not localhost

### Performance Issues

#### Slow Response Times
**Symptoms**: AI responses are slow or timeout

**Diagnosis**:
```bash
# Check Ollama service
curl http://localhost:11434/api/version

# Check model availability
ollama list

# Monitor resource usage
docker stats
```

**Solutions**:
1. **Ollama not running**: Start Ollama service
2. **Model not loaded**: Pull required models
3. **Resource constraints**: Increase VM resources

```bash
# Start Ollama
ollama serve

# Pull models
ollama pull qwen2.5:7b
ollama pull llama3.2:3b
```

#### Memory Issues
**Symptoms**: Services crash due to memory exhaustion

**Diagnosis**:
```bash
# Check memory usage
free -h
docker stats

# Check swap
swapon --show
```

**Solutions**:
1. **Increase VM memory**: Allocate more RAM
2. **Enable swap**: Add swap space
3. **Optimize models**: Use smaller models

```bash
# Add swap (if needed)
sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

### Data Issues

#### Vector Database Problems
**Symptoms**: RAG not working, search failures

**Diagnosis**:
```bash
# Check Qdrant status
curl http://localhost:6333/health

# Check collections
curl http://localhost:6333/collections
```

**Solutions**:
1. **Restart Qdrant**: `docker compose restart qdrant`
2. **Check disk space**: Ensure sufficient storage
3. **Recreate collections**: Delete and recreate if corrupted

#### Database Connection Issues
**Symptoms**: n8n can't connect to PostgreSQL

**Diagnosis**:
```bash
# Check PostgreSQL
docker compose exec postgres pg_isready

# Test connection
docker compose exec postgres psql -U n8n -d n8n -c "SELECT 1;"
```

**Solutions**:
1. **Restart PostgreSQL**: `docker compose restart postgres`
2. **Check credentials**: Verify .env file
3. **Reset database**: Use init.sh with DEV_MODE=true

### Configuration Issues

#### Environment Variables
**Symptoms**: Services fail with configuration errors

**Diagnosis**:
```bash
# Check .env file
cat .env

# Verify variables
docker compose config
```

**Solutions**:
1. **Regenerate .env**: Delete and run init.sh
2. **Fix syntax**: Check for missing quotes or spaces
3. **Update passwords**: Ensure strong passwords

#### Port Conflicts
**Symptoms**: Services fail to bind to ports

**Diagnosis**:
```bash
# Check port usage
netstat -tuln | grep -E "(8081|5678|3300|8082|6333)"

# Check Docker ports
docker compose ps
```

**Solutions**:
1. **Change ports**: Update .env file
2. **Stop conflicting services**: Identify and stop other services
3. **Use different ports**: Modify docker-compose.yml

### Authentication Issues

#### Login Problems
**Symptoms**: Can't access web interfaces

**Diagnosis**:
```bash
# Check credentials in .env
grep -E "(USER|PASSWORD|EMAIL)" .env

# Test service endpoints
curl -I http://localhost:8081
curl -I http://localhost:5678
```

**Solutions**:
1. **Reset passwords**: Regenerate in .env
2. **Clear browser cache**: Clear cookies and cache
3. **Check service status**: Ensure services are running

#### API Authentication
**Symptoms**: API calls fail with auth errors

**Diagnosis**:
```bash
# Check API keys
curl -H "Authorization: Bearer $API_KEY" http://localhost:8081/api/v1/chat
```

**Solutions**:
1. **Regenerate API keys**: Create new keys in service settings
2. **Check token format**: Ensure proper Bearer token format
3. **Verify permissions**: Check user permissions

## Diagnostic Commands

### System Health Check
```bash
#!/bin/bash
# health-check.sh

echo "=== System Resources ==="
free -h
df -h
uptime

echo "=== Docker Status ==="
docker --version
docker compose version
docker compose ps

echo "=== Service Health ==="
curl -s http://localhost:8081 > /dev/null && echo "OpenWebUI: OK" || echo "OpenWebUI: FAIL"
curl -s http://localhost:5678 > /dev/null && echo "n8n: OK" || echo "n8n: FAIL"
curl -s http://localhost:3300 > /dev/null && echo "Langfuse: OK" || echo "Langfuse: FAIL"
curl -s http://localhost:8082 > /dev/null && echo "SearxNG: OK" || echo "SearxNG: FAIL"
curl -s http://localhost:6333 > /dev/null && echo "Qdrant: OK" || echo "Qdrant: FAIL"

echo "=== Ollama Status ==="
curl -s http://localhost:11434/api/version > /dev/null && echo "Ollama: OK" || echo "Ollama: FAIL"

echo "=== Network Connectivity ==="
docker compose exec openwebui ping -c 1 postgres > /dev/null && echo "OpenWebUI -> PostgreSQL: OK" || echo "OpenWebUI -> PostgreSQL: FAIL"
docker compose exec n8n ping -c 1 qdrant > /dev/null && echo "n8n -> Qdrant: OK" || echo "n8n -> Qdrant: FAIL"
```

### Log Analysis
```bash
# Service logs
docker compose logs --tail=100 [service-name]

# Application logs
tail -100 logs/init-*.log

# System logs
journalctl -u docker.service --since "1 hour ago"
```

### Performance Monitoring
```bash
# Resource usage
docker stats --no-stream

# Network monitoring
docker compose exec [service] netstat -tuln

# Database performance
docker compose exec postgres psql -U n8n -d n8n -c "SELECT * FROM pg_stat_activity;"
```

## Recovery Procedures

### Complete Reset
```bash
# WARNING: This will delete all data
# Edit init.sh: set DEV_MODE=true
./init.sh
```

### Service Recovery
```bash
# Restart specific service
docker compose restart [service-name]

# Restart all services
docker compose down
docker compose up -d
```

### Data Recovery
```bash
# Restore from backup
tar -xzf backup/ai_data.tar.gz
docker compose exec -T postgres psql -U n8n n8n < backup/postgres.sql
docker compose restart
```

## Getting Help

### Before Asking for Help
1. **Check logs**: Review service and application logs
2. **Run diagnostics**: Use health-check script
3. **Verify prerequisites**: Ensure system requirements are met
4. **Search issues**: Check GitHub issues for similar problems

### Information to Provide
When reporting issues, include:
- **System information**: OS, Docker version, hardware specs
- **Error messages**: Complete error output
- **Logs**: Relevant log excerpts
- **Steps to reproduce**: Clear reproduction steps
- **Environment**: .env file (without passwords)

### Support Channels
- **GitHub Issues**: For bug reports and feature requests
- **Documentation**: Check existing docs first
- **Community**: GitHub discussions

---

**Related**: [SETUP.md](SETUP.md) | [USER_GUIDE.md](USER_GUIDE.md) | [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md)
