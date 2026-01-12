---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:32.957470'
id: a9d5d6d8-d8bc-401c-af91-213f2e16a1de
title: doc-a9d5d6d8-d8bc-401c-af91-213f2e16a1de
---

Ollama (ollama)
						
 
llama3.1, codellama, mistral

Show more3.1. Configuring the model secret keyCopier lienLien copié sur presse-papiers!
				You must configure the Kubernetes secret for the large language model (LLM) provider in the OpenShift Container Platform project where you installed the MTA operator.
			Note
					You can replace oc in the following commands with kubectl.
				Procedure
						Create a credentials secret named kai-api-keys in the openshift-mta project.
					
								For Amazon Bedrock as the provider, type:
							
oc create secret generic aws-credentials \
 --from-literal=AWS_ACCESS_KEY_ID=<YOUR_AWS_ACCESS_KEY_ID> \
 --from-literal=AWS_SECRET_ACCESS_KEY=<YOUR_AWS_SECRET_ACCESS_KEY>
oc create secret generic aws-credentials \
 --from-literal=AWS_ACCESS_KEY_ID=<YOUR_AWS_ACCESS_KEY_ID> \
 --from-literal=AWS_SECRET_ACCESS_KEY=<YOUR_AWS_SECRET_ACCESS_KEY>




Copy to Clipboard
Copied!










Toggle word wrap
Toggle overflow