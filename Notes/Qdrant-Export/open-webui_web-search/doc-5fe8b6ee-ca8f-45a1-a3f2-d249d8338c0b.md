---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:32.173432'
id: 5fe8b6ee-ca8f-45a1-a3f2-d249d8338c0b
title: doc-5fe8b6ee-ca8f-45a1-a3f2-d249d8338c0b
---

September 08, 2025



Peter Robinson Initial Minimal Fedora Image for Raspberry Pi 5
I know this has been much awaited because of all the queries on the various forums and direct to me so here we are the first Fedora image that can run a native userspace with a Fedora kernel with some enablement patches.
This image is far from complete and is NOT yet suitable for desktop UXes and related usecases that require a display.
So what works, what doesn’t, and how can you get started?
The things that are working and tested:

The original RPi5 rev c0 SoCs: the older 4Gb/8Gb variants
Serial console
Late boot HDMI0 display output (IE once the kernel has started) via simple DRM/FB
The compute Subsystems (CPUs etc) of both SoC revs
The micro SD slot – the only supported OS disk ATM
Wired ethernet port
Wireless network interface
USB ports (NOT for OS disks)

The things that don’t work: