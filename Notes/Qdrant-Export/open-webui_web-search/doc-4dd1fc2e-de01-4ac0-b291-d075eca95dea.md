---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:31.985766'
id: 4dd1fc2e-de01-4ac0-b291-d075eca95dea
title: doc-4dd1fc2e-de01-4ac0-b291-d075eca95dea
---

Then the container needs to be run with access to the GPUs, by adding the --gpus option to the baseline command above:
$ podman run \
    --gpus all \
    --name ollama \
    --publish 11434:11434 \
    --rm \
    --security-opt label=disable \
    --volume ~/.ollama:/root/.ollama \
    docker.io/ollama/ollama:latest