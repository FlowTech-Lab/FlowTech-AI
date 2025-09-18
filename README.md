#FlowTech-AI

## Premier démarrage

./init.sh
docker compose up -d

Dans Panneau administrateur > Reglages > recherche WEb "http://searxng:8080/search"

















Bonnus : Instrallation de ollama et modèles de bases


# (re)start Ollama GPU en propre
docker rm -f ollama >/dev/null 2>&1 || true
docker run --gpus all -d --restart unless-stopped \
  -p 11434:11434 -v /opt/ollama:/root/.ollama \
  --name ollama ollama/ollama:latest

# 2) Tirer un modèle sûr pour 6 Go VRAM (petit, rapide)
#docker exec -it ollama ollama pull llama3.2:3b

# Option: tenter un 7B quantisé (peut passer sur 6 Go selon contexte)
docker exec -it ollama ollama pull qwen2.5:7b
docker exec -it ollama ollama pull huihui_ai/qwen2.5-1m-abliterated:7b
# docker exec -it ollama ollama pull mistral:7b

# smoke test API locale
echo '[TEST] generate'
curl -s http://127.0.0.1:11434/api/generate \
  -d '{"model":"llama3.2:3b","prompt":"Donne exactement 5 parfums de glace, une puce par ligne, en français.","stream":false}'

# IP hôte à utiliser depuis le client
echo -e "\n[HOST_IP]"
hostname -I | awk '{print $1}'