---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:33.149846'
id: bee64291-e4fc-47ac-90ce-d434d1e0e7a7
title: doc-bee64291-e4fc-47ac-90ce-d434d1e0e7a7
---

#!/bin/bashDATE=$(date)echo {\"date\" : \"${DATE}\"}
ou en python qui retourne de l’ini :
#!/usr/bin/env python3
import osimport subprocessfrom datetime import datetime
def get_last_reboot():    """Returns the date and time of the last reboot."""    try:        last_reboot_time = subprocess.check_output(['who', '-b']).decode().strip().split(' ')        last_reboot_date = last_reboot_time[2] + ' ' + last_reboot_time[3]        return last_reboot_date    except Exception as e:        return f"Error fetching last reboot time: {str(e)}"