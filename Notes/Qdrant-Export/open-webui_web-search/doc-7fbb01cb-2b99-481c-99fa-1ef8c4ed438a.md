---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:32.555355'
id: 7fbb01cb-2b99-481c-99fa-1ef8c4ed438a
title: doc-7fbb01cb-2b99-481c-99fa-1ef8c4ed438a
---

One of the common aspects of these long running tasks is that they are built out of smaller elements, but need to perform all of the elements in order to validate some prerequisite.  Perhaps that prerequisite is starting from a know state, either of the machine of the build.The problem with automation is that it forces you to go through all the steps.  While that is sometimes a necessary and right approach, it is not for all development.I am going to make a distinction here between tools and automation.  The distinction is that a tool is designed to be used by the software craftsman to perform and operation, maybe several, in the course of interactive work.  The tools may be as simple as ‘ls’ which lists the contents of a directory, or as complex as tcpdump/wireshare/netstat type tools that show network state in flight.  Automation is explicitly not for this use case: automation is to replace time consuming and error prone tasks with repeatable, deterministic processing.  Automation