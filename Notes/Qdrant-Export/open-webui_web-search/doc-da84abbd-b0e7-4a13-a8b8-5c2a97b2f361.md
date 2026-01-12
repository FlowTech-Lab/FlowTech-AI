---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:33.370805'
id: da84abbd-b0e7-4a13-a8b8-5c2a97b2f361
title: doc-da84abbd-b0e7-4a13-a8b8-5c2a97b2f361
---

You need to modify the ExecStart line to add client options with the -t arguments. For example I added:
-t fontSize=14 -t "fontFamily=monospace" -t 'theme={"foreground": "white", "background": "black"}'