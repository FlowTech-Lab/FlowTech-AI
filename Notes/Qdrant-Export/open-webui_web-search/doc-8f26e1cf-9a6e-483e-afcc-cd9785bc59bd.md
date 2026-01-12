---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:32.676895'
id: 8f26e1cf-9a6e-483e-afcc-cd9785bc59bd
title: doc-8f26e1cf-9a6e-483e-afcc-cd9785bc59bd
---

Copy to Clipboard
Copied!










Toggle word wrap
Toggle overflow
















Note
									You can also set the base URL as the kai_llm_baseurl variable in the Tackle custom resource.
								
						(Optional) Force a reconcile so that the MTA operator picks up the secret immediately
					
kubectl patch tackle tackle -n openshift-mta --type=merge -p \
'{"metadata":{"annotations":{"konveyor.io/force-reconcile":"'"$(date +%s)"'"}}}'
kubectl patch tackle tackle -n openshift-mta --type=merge -p \
'{"metadata":{"annotations":{"konveyor.io/force-reconcile":"'"$(date +%s)"'"}}}'




Copy to Clipboard
Copied!










Toggle word wrap
Toggle overflow