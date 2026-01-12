---
collection: cursor-context
exported_at: '2026-01-11T22:30:22.005157'
id: 37b18f00-ecec-4a0f-be8c-14a01d6e3dae
title: doc-37b18f00-ecec-4a0f-be8c-14a01d6e3dae
---

Configuration finale validée Raspberry Pi 4 + Proxmox VE pour mémoire et ZFS. ZFS ARC limité 256MB/64MB, ZRAM 1.5GB zstd priorité 100, sysctl optimisé (swappiness=60, page-cluster=0), zswap désactivé. Inclut service systemd dédié, vérifications complètes, opérations courantes, et valeurs finales retenues. Configuration testée et reproductible pour stabilité Pi 4.