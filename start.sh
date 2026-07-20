#!/bin/bash

# 1. पुरानी किसी भी बची हुई लॉक फाइल्स को साफ करें
rm -rf /var/run/xrdp/* /var/run/dbus/* /tmp/.X11-unix/X*

# 2. D-Bus Daemon को बैकग्राउंड में चलाएं
dbus-daemon --system --fork

# 3. xrdp-sesman को शुरू करें
xrdp-sesman

# 4. xrdp को फ़ोरग्राउंड में चलाएं
echo "Launching Linux Mint Cinnamon RDP Server..."
exec xrdp --nodaemon
