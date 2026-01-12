---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:31.295304'
id: 0982f9c9-739d-46bb-8fae-07aa48ccc1ca
title: doc-0982f9c9-739d-46bb-8fae-07aa48ccc1ca
---

Communishift upgrades
Our communishift cluster is a openshift dedicated cluster running in aws.
However, I had noted that it wasn't upgrading from the 4.16.x version it
had for a while. Turns out that it needed to have it's networking setup
migrated from SDN to OVH, which isn't something they do, but we need to do.
So, I did that and then also upgraded it to 4.17.x and will do 4.18.x and 4.19.x
as soon as the upgrade is available on it.