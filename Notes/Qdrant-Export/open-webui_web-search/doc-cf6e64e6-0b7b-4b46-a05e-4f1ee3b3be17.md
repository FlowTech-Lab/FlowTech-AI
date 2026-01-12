---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:33.273520'
id: cf6e64e6-0b7b-4b46-a05e-4f1ee3b3be17
title: doc-cf6e64e6-0b7b-4b46-a05e-4f1ee3b3be17
---

Peter Hutterer Why is my device a touchpad and a mouse and a keyboard?

If you have spent any time around HID devices under Linux (for example if you
are an avid mouse, touchpad or keyboard user) then you may have noticed that
your single physical device actually shows up as multiple device nodes (for
free! and nothing happens for free these days!).
If you haven't noticed this, run libinput record and you may be
part of the lucky roughly 50% who get free extra event nodes.


The pattern is always the same. Assuming you have a device named 
FooBar ExceptionalDog 2000 AI[1] what you will see are multiple devices

/dev/input/event0: FooBar ExceptionalDog 2000 AI Mouse
/dev/input/event1: FooBar ExceptionalDog 2000 AI Keybard 
/dev/input/event2: FooBar ExceptionalDog 2000 AI Consumer Control 


The Mouse/Keyboard/Consumer Control/... suffixes are a quirk of the kernel's
HID implementation which splits out a device based on the Application Collection. [2]