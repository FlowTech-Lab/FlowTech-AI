---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:31.274415'
id: 054abe5b-131f-4cbf-9de2-f6dcbe2893cc
title: doc-054abe5b-131f-4cbf-9de2-f6dcbe2893cc
---

kubectl get po,svc -n kubevirt-managerNAME                                    READY   STATUS    RESTARTS   AGEpod/kubevirt-manager-5858499887-wfrgn   1/1     Running   0          4m56sNAME                       TYPE           CLUSTER-IP    EXTERNAL-IP    PORT(S)          AGEservice/kubevirt-manager   LoadBalancer   10.0.173.82   20.74.99.190   8080:30143/TCP   4m24sPress enter or click to view image in full sizeEt j’y accède via l’adresse IP publique fournie dans AKS :Press enter or click to view image in full sizePress enter or click to view image in full sizePress enter or click to view image in full sizeKrew est installé localement via Kubectl ainsi que le plugin correspondant pour Kubevirt :QuickstartKrew helps you discover and install kubectl plugins on your machine. You can install and use a wide variety of kubectl…krew.sigs.k8s.io$ kubectl krew updateUpdated the local copy of plugin index.$ kubectl krew search virtNAME                            DESCRIPTION