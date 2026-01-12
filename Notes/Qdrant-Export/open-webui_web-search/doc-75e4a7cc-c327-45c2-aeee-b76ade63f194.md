---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:32.374639'
id: 75e4a7cc-c327-45c2-aeee-b76ade63f194
title: doc-75e4a7cc-c327-45c2-aeee-b76ade63f194
---

Even though, /usr is read-only on Silverblue, /usr/local is not, because it’s a symbolic link to /var/usrlocal, and Fedora defaults to putting /usr/local/bin earlier in the PATH environment variable than the other prefixes that the installer attempts to use, as long as pkexec(1) isn’t being used.  This happy coincidence allows the installer to place the Ollama binaries in their right places.
The script does fail eventually when attempting to create the systemd service unit to run ollama serve, because it tries to create an ollama user with /usr/share/ollama as its home directory.  However, this half-baked installation works surprisingly well as long as nobody is trying to use an AMD GPU.
NVIDIA GPUs work, if the proprietary driver and nvidia-smi(1) are present in the operating system, which are provided by the kmod-nvidia and xorg-x11-drv-nvidia-cuda packages from RPM Fusion; and so does CPU fallback.