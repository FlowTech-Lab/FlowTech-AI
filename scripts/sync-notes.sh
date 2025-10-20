#!/bin/bash
# Wrapper script to sync Notes/ to Qdrant cursor-knowledge collection
# Run this manually or via cron

set -e

# Change to FlowTech-AI directory
cd "$(dirname "$0")/.."

# Set environment variables
export QDRANT_URL="http://localhost:6333"
export COLLECTION_NAME="cursor-knowledge"
export EMBEDDING_MODEL="BAAI/bge-large-en-v1.5"
export NOTES_PATH="./Notes"
export CACHE_FILE="./AI_Data/notes-sync-cache.json"

# Run sync script
exec ./scripts/venv/bin/python ./scripts/sync-notes-to-qdrant.py "$@"

