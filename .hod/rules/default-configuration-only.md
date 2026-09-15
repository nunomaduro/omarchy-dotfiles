---
name: default-configuration-only
description: What this project holds when the user asks for an application.
---

# Default configuration only

When the user asks for an application in this project, install that application and write no configuration file for it. A request for an application is a request to install it, and it is not a request to copy the configuration of that application from the machine of the user.

Write a file under `home/` for that application only when the user names a change to the default configuration. Write in that file the change that the user names, and write no different value.
