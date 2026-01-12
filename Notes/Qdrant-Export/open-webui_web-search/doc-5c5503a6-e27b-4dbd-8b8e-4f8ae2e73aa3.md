---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:32.159105'
id: 5c5503a6-e27b-4dbd-8b8e-4f8ae2e73aa3
title: doc-5c5503a6-e27b-4dbd-8b8e-4f8ae2e73aa3
---

The syslog-ng application is part of all major Linux distributions, and you can usually install syslog-ng from the official repositories. If you use just the core functionality of syslog-ng, use the package in your distribution repository (apt-get install syslog-ng), and you can stop reading here. However, if you want to use the features of newer syslog-ng versions (for example, send log messages to Elasticsearch or Apache Kafka), you have to either compile the syslog-ng from source, or install it from unofficial repositories. This post explains you how to do that.
For information on all platforms that could be relevant to you, check out all my blog posts about installing syslog-ng on major Linux distributions, collected in one place.
In addition, syslog-ng is also available as a Docker image. To learn more, read our tutorial about logging in Docker using syslog-ng.
Why is syslog-ng in my distribution so old?