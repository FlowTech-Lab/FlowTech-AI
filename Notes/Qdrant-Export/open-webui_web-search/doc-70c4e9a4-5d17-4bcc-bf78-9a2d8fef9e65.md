---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:32.354587'
id: 70c4e9a4-5d17-4bcc-bf78-9a2d8fef9e65
title: doc-70c4e9a4-5d17-4bcc-bf78-9a2d8fef9e65
---

Set each variable: For each environment variable you want to set, use the launchctl setenv command. For instance:
launchctl setenv OLLAMA_HOST "0.0.0.0"
launchctl setenv OLLAMA_MODELS "/path/to/your/models"

Restart Ollama: After setting the variables, restart the Ollama application for the changes to take effect.

Linux
On Linux, if Ollama is running as a systemd service, use systemctl to set the environment variables:

Edit the systemd service file: Run systemctl edit ollama.service. This will open the service file in a text editor.
Add environment variables: Under the [Service] section, add a line for each environment variable using the Environment= directive:
[Service]
Environment="OLLAMA_HOST=0.0.0.0"
Environment="OLLAMA_MODELS=/path/to/your/models"

Reload and restart: Save the file, exit the editor, and then run the following commands:
systemctl daemon-reload
systemctl restart ollama


Windows
On Windows, Ollama inherits your user and system environment variables: