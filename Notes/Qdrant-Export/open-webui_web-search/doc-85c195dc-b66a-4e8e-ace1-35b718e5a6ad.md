---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:32.579589'
id: 85c195dc-b66a-4e8e-ace1-35b718e5a6ad
title: doc-85c195dc-b66a-4e8e-ace1-35b718e5a6ad
---

# Enable memory debugging
export OLLAMA_DEBUG=1
These settings minimize memory usage at the cost of performance. Monitor system memory usage and adjust accordingly.High-Performance ConfigurationsMaximize performance on powerful hardware:# High-performance settings
export OLLAMA_NUM_PARALLEL=8
export OLLAMA_MAX_LOADED_MODELS=5
export OLLAMA_KEEP_ALIVE=30m
export OLLAMA_GPU_OVERHEAD=2147483648

# Enable performance logging
export OLLAMA_FLASH_ATTENTION=1
High-performance configurations require substantial system resources. Ensure adequate cooling and power supply for sustained operation.GPU Optimization TechniquesFine-tune GPU utilization for different scenarios:# NVIDIA GPU optimization
export CUDA_VISIBLE_DEVICES=0
export OLLAMA_GPU_OVERHEAD=1536000000  # 1.5GB overhead

# AMD GPU configuration (ROCm)
export HSA_OVERRIDE_GFX_VERSION=10.3.0
export OLLAMA_GPU_LAYERS=32