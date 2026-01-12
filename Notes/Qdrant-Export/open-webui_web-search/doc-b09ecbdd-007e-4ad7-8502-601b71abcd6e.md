---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:32.978741'
id: b09ecbdd-007e-4ad7-8502-601b71abcd6e
title: doc-b09ecbdd-007e-4ad7-8502-601b71abcd6e
---

Enable-Debug: off
Enable-GProf: off
Enable-Memtrace: off
Enable-IPv6: on
Enable-Spoof-Source: on
Enable-TCP-Wrapper: on
Enable-Linux-Caps: on
Enable-Systemd: on
root@ubi2204:~# logger this is a test
root@ubi2204:~# tail -f /var/log/messages
Jun 24 15:42:43 ubi2204 root[4753]: this is a test
root@ubi2204:~#
What is next?
We hope you find the nightly builds useful. Please share your experiences with these packages, we are interested in both your positive and negative reviews.
Finally, let me repeat, these packages are not intended for use in production, they are only for testing new features and bug fixes.