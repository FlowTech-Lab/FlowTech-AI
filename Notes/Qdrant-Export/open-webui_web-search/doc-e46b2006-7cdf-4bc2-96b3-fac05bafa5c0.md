---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:33.468094'
id: e46b2006-7cdf-4bc2-96b3-fac05bafa5c0
title: doc-e46b2006-7cdf-4bc2-96b3-fac05bafa5c0
---

For a model named "my-model" deployed in OpenShift AI with "example-model" as the serving name:
			
models:
  openshift-example-model: &active
    environment:
      CA_BUNDLE: "<Servers CA Bundle path>"
    provider: "ChatOpenAI"
    args:
      model: "my-model"
      configuration:
        baseURL: "https://<serving-name>-<data-science-project-name>.apps.konveyor-ai.example.com/v1"
models:
  openshift-example-model: &active
    environment:
      CA_BUNDLE: "<Servers CA Bundle path>"
    provider: "ChatOpenAI"
    args:
      model: "my-model"
      configuration:
        baseURL: "https://<serving-name>-<data-science-project-name>.apps.konveyor-ai.example.com/v1"