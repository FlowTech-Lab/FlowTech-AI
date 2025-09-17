#FlowTech-AI

## Premier démarrage

./init.sh
docker compose up -d

Dans Panneau administrateur > Reglages > recherche WEb "http://searxng:8080/search"

set -euo pipefail

# (re)start Ollama GPU en propre
docker rm -f ollama >/dev/null 2>&1 || true
docker run --gpus all -d --restart unless-stopped \
  -p 11434:11434 -v /opt/ollama:/root/.ollama \
  --name ollama ollama/ollama:latest

# 2) Tirer un modèle sûr pour 6 Go VRAM (petit, rapide)
#docker exec -it ollama ollama pull llama3.2:3b

# Option: tenter un 7B quantisé (peut passer sur 6 Go selon contexte)
docker exec -it ollama ollama pull qwen2.5:7b
docker exec -it ollama ollama pull wizard-vicuna-uncensored:7b
docker exec -it ollama ollama pull huihui_ai/deepseek-r1-abliterated:7b
docker exec -it ollama ollama pull huihui_ai/qwen2.5-1m-abliterated:7b
# docker exec -it ollama ollama pull mistral:7b

# smoke test API locale
echo '[TEST] generate'
curl -s http://127.0.0.1:11434/api/generate \
  -d '{"model":"llama3.2:3b","prompt":"Donne exactement 5 parfums de glace, une puce par ligne, en français.","stream":false}'

# IP hôte à utiliser depuis ta VM Ruby/n8n
echo -e "\n[HOST_IP]"
hostname -I | awk '{print $1}'













# 📌 Cahier des Charges – IA Personnelle FlowTech (Mise à jour)

## 1️⃣ **Objectifs & Finalité**  

### 🎯 **But Principal :**  
Déployer une **IA personnelle locale** pour assister FlowTech dans ses projets techniques, ses développements et la documentation de ses travaux. L’IA doit être capable de :  
- ✅ **Assistance technique multi-domaines** : tuning FPV, Proxmox, Docker, réseau, infrastructure, etc.  
- ✅ **Analyse & organisation de fichiers** : lecture et modification de logs, configurations, code source, documentation technique.  
- ✅ **Contexte en temps réel** : prendre en compte l’état actuel des systèmes et suggérer des solutions optimales.  
- ✅ **Planification & exécution** : proposer des plans d’action et les dérouler automatiquement après validation.  
- ✅ **Apprentissage continu** : mémoriser l’historique des interactions et améliorer ses conseils au fil du temps.  
- ✅ **Recherche Internet si besoin** : être capable de rechercher des informations en ligne si nécessaire.  

### 👤 **Usage privé** : L’IA est strictement réservée à FlowTech.  
### ☁️ **Environnement hybride** : Fonctionnement principalement en local, avec utilisation du cloud uniquement si nécessaire.

---

## 2️⃣ **Architecture & Déploiement**  

### 💾 **Infrastructure cible :**  
- **Développement & Tests** : PC Fixe (Windows + WSL) avec GPU **RTX 4070**.  
- **Production locale** : Serveur **Proxmox** (Linux) avec GPU **GTX 1660 Ti**, hébergeant un conteneur ou VM Docker pour l’IA. Stockage principal sur **Nextcloud (Btrfs)**.  
- **Cloud (optionnel)** : Utilisation ponctuelle pour des calculs lourds ou des recherches web avancées.

### 🔧 **Technologies principales :**  
- **Backend IA** : Python (**FastAPI** ou **Flask**) pour orchestrer les composants.  
- **LLM locaux** : **Ollama** pour héberger des modèles locaux (ex : Mistral 7B/Mixtral, Phi-3, etc.).  
- **Orchestration & Interface** :  
  - **Interface principale** : **OpenWebUI** comme UI principale pour converser avec l’IA.  
  - **Automatisation** : **n8n** pour exécuter les tâches d'automatisation et orchestrer les workflows.  
- **Mémoire IA & base de connaissance** :  
  - **ChromaDB** (mémoire vectorielle intégrée à OpenWebUI) pour stocker les connaissances et documents.  
  - **Weaviate ou Qdrant** (évolution possible si besoin d'une base plus puissante et rapide).  
- **Stockage des fichiers projet** : **Nextcloud** (serveur de fichiers, logs, configs, code source, etc.).

### 🌐 **Interface utilisateur :**  
- **Interface Web conversationnelle** via OpenWebUI.  
- **Mode vocal** (optionnel) pour interaction mains libres.  
- **Gestion des conversations & mémoire longue durée**.  
- **Possibilité d’intégrer une API REST** pour des automatisations avancées.

---

## 3️⃣ **Gestion des Fichiers & Données**  

### 📂 **Types de fichiers gérés :**  
- **Configurations techniques** : fichiers Betaflight, Docker, Proxmox, etc.  
- **Logs système et applicatifs** : serveurs Proxmox, journaux Docker, Nextcloud, etc.  
- **Documents techniques** : README, Markdown, manuels PDF, JSON/YAML.  

### 🔍 **Accès & modifications :**  
- **Lecture des fichiers** : via **API WebDAV de Nextcloud**.  
- **Modification des fichiers** : initialement avec validation manuelle, puis automatisation avec workflows n8n.  
- **Indexation en temps réel** pour garder la base de connaissances toujours à jour.  
- **Organisation automatique des fichiers** (tagging, tri, renommage automatisé).  

---

## 4️⃣ **Fonctionnalités IA & Apprentissage**  

### 🧠 **Capacités d’apprentissage :**  
- **Mémoire conversationnelle** : suivi du contexte et adaptation en fonction des échanges passés.  
- **Apprentissage progressif** : amélioration continue des suggestions en fonction du feedback.  
- **Stockage long-terme** : via **ChromaDB** et potentiellement **Weaviate/Qdrant** si évolutif.

### 🔍 **Tâches gérées par l’IA :**  
- **Planification de projets** : structuration et identification des obstacles.  
- **Optimisation de configurations** : tuning FPV, réglages Docker, Proxmox.  
- **Dépannage & Debug** : analyse de logs et détection des erreurs.  
- **Documentation & synthèse** : génération automatique de rapports techniques.  

### 🤖 **Automatisation avancée avec n8n :**  
- **Déclenchement de workflows** sur base de règles définies.  
- **Automatisation des tâches courantes** (gestion de fichiers, backup, maintenance serveurs).  
- **Interaction avec d’autres outils** : Discord, Nextcloud, Grafana, etc.  

---

## 5️⃣ **Sécurité & Accès**  

### 🔐 **Contrôle d’accès :**  
- **Authentification sécurisée** pour OpenWebUI et les API.  
- **Données privées stockées uniquement en local** (aucune fuite vers le cloud sans validation).  
- **Logs d’interactions** stockés localement et consultables.  

### 🛡️ **Sécurité opérationnelle :**  
- **Pas d’accès direct aux systèmes critiques** au départ.  
- **Toute action critique validée manuellement** avant exécution.  
- **Mise à jour manuelle du système** pour garder un contrôle total.  

---

## 6️⃣ **Intégration avec les Projets FlowTech**  

### 📡 **Écosystème FlowTech :**  
- **Connexion avec Nextcloud** pour lecture et modification des fichiers.  
- **Automatisation avancée via n8n** pour exécuter des actions sur Proxmox, Docker, etc.  
- **Notifications Discord/Telegram** pour suivi des tâches automatisées.  
- **Interaction avec Grafana et outils de monitoring** pour interprétation des métriques système.  

---

## 7️⃣ **Plan de Déploiement & Prochaines Étapes**  

### 📦 **Déploiement initial :**  
1. **Installation OpenWebUI + ChromaDB** sur le serveur Proxmox.  
2. **Connexion d’Ollama** pour exécuter un modèle local.  
3. **Intégration Nextcloud (lecture de fichiers)**.  
4. **Développement des premiers workflows n8n** pour automatiser des tâches simples.  

### 🚀 **Évolutions futures :**  
1. **Mise en place de l’édition de fichiers Nextcloud** avec validation manuelle.  
2. **Optimisation de la mémoire vectorielle** (test de Weaviate/Qdrant si besoin).  
3. **Déploiement progressif des automatisations avancées** avec agents IA autonomes.  

---

## 📌 **Résumé des mises à jour :**  
✅ **OpenWebUI comme interface principale**  
✅ **n8n pour automatiser les actions**  
✅ **ChromaDB pour la mémoire vectorielle, avec possibilité d’évolution vers Weaviate/Qdrant**  
✅ **IA capable de modifier les fichiers après validation**  
✅ **Optimisation progressive avec tests en conditions réelles**  

Avec ce plan, l’IA sera **100% locale, intelligente et évolutive**, répondant aux besoins de FlowTech. 🚀

