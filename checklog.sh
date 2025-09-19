# 1) Démarrage
docker compose up -d

# 2) Postgres healthy + DB langfuse ok
CID_PG=$(docker compose ps -q postgres)
for i in {1..60}; do s=$(docker inspect -f '{{.State.Health.Status}}' "$CID_PG" 2>/dev/null || true); [ "$s" = "healthy" ] && break; sleep 1; done
[ "$s" = "healthy" ] || { echo "Postgres non healthy"; exit 1; }
PGU=$(grep -E '^POSTGRES_USER=' .env | cut -d= -f2)
docker compose exec -T postgres psql -U "$PGU" -tc "SELECT 1 FROM pg_database WHERE datname='langfuse'" | grep -q 1 \
  || docker compose exec -T postgres psql -U "$PGU" -c 'CREATE DATABASE langfuse;'

# 3) État des conteneurs
docker compose ps

# 4) Ports exposés (utile pour Langfuse)
docker compose port qdrant 6333
docker compose port openwebui 8080
docker compose port searxng 8080
docker compose port n8n 5678
docker compose port langfuse-web 3000

# 5) Checks HTTP rapides
curl -sI http://localhost:6333 | head -n1         # Qdrant
curl -sI http://localhost:8081 | head -n1         # OpenWebUI
curl -sI http://localhost:8082 | head -n1         # SearxNG
curl -sI http://localhost:5678 | head -n1         # n8n
LF_PORT=$(grep -E '^LANGFUSE_PORT=' .env | cut -d= -f2)
curl -sI "http://localhost:${LF_PORT}" | head -n1 # Langfuse

# 6) Env critique dans les conteneurs
CID_OWUI=$(docker compose ps -q openwebui)
docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' "$CID_OWUI" | egrep '^(VECTOR_DB|RAG_VECTOR_DB|QDRANT_URI)=' || echo "RAG non activé"

CID_LF_WEB=$(docker compose ps -q langfuse-web)
docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' "$CID_LF_WEB" | egrep '^(DATABASE_URL|NEXTAUTH_URL|NEXTAUTH_SECRET|SALT|ENCRYPTION_KEY)='

# 7) Logs ciblés (2 dernières minutes)
for s in postgres qdrant openwebui searxng n8n langfuse-web langfuse-worker; do
  echo "===== $s ====="; docker compose logs --since=2m "$s" | tail -n +1 || true
done
