---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:32.684339'
id: 90bf4d9e-f73f-4df1-89fd-e0fe88eba62a
title: doc-90bf4d9e-f73f-4df1-89fd-e0fe88eba62a
---

Copy to Clipboard
Copied!










Toggle word wrap
Toggle overflow

















						In the Red Hat Developer Lightspeed for MTA extension, type Open the GenAI model provider configuration file in the Command Palette to open the provider-settings.yaml file.
					
						Enter the model details from Podman Desktop. For example, use the following configuration for a Mistral model.
					
podman_mistral: &active
    provider: "ChatOpenAI"
     environment:
      OPENAI_API_KEY: "unused value"
    args:
      model: "mistral-7b-instruct-v0-2"
      base_url: "http://localhost:35841/v1"
podman_mistral: &active
    provider: "ChatOpenAI"
     environment:
      OPENAI_API_KEY: "unused value"
    args:
      model: "mistral-7b-instruct-v0-2"
      base_url: "http://localhost:35841/v1"




Copy to Clipboard
Copied!










Toggle word wrap
Toggle overflow