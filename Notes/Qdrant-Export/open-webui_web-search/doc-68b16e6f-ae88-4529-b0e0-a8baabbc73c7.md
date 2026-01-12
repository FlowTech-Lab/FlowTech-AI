---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:32.267197'
id: 68b16e6f-ae88-4529-b0e0-a8baabbc73c7
title: doc-68b16e6f-ae88-4529-b0e0-a8baabbc73c7
---

Anubis rollout
Last week I was testing anubis in staging, but this week I rolled it out to
production in a number of places. The biggest win was pagure.io, which has
been particularly hard hit by scrapers.
Here's the load last week, can you tell when anubis was enabled?



I then enabled things for a bunch of other sites of ours: koji, src,
koschei, lists, etc.
There's still 2 outstanding issues I know of:

Some folks have reported that it's giving them challenges all the time.
I'm not sure why this would be happening, but hopefully we can track it down.
rss feeds on bodhi and badges aren't working anymore. I need to allow the
rss feed paths that they use. In the mean time using a user-agent without
Mozilla in it should work around that.

So, hopefully that saves us a bunch of bandwith, cpu time, database cycles
and more. Thanks anubis developers!