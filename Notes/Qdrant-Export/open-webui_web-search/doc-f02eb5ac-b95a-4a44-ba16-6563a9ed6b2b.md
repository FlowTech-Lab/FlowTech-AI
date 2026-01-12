---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:33.572466'
id: f02eb5ac-b95a-4a44-ba16-6563a9ed6b2b
title: doc-f02eb5ac-b95a-4a44-ba16-6563a9ed6b2b
---

Looking for RPM packages? Check my previous blog covering RPM packages.
Which package to install?
You can use many sources and destinations in syslog-ng. The majority of these require additional dependencies to be installed. If all of the features would be packaged into a single package, installing syslog-ng would also install dozens of other smaller and larger dependencies, including such behemoths as Java. This is why the syslog-ng-core package includes only the core functionality, whereas features requiring additional dependencies are available as sub-packages. The most popular sub-package is syslog-ng-mod-http, which allows you to log to Elasticsearch and many cloud services, but there are many others as well. The command “apt-cache search syslog-ng” will list you all the possibilities.