#!/bin/bash
# Watch for macOS application focus changes and refresh simple-bar
LAST_APP=""
while true; do
  CURRENT_APP=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null)
  if [ "$CURRENT_APP" != "$LAST_APP" ]; then
    LAST_APP="$CURRENT_APP"
    curl -s http://localhost:7776/aerospace/spaces/refresh > /dev/null 2>&1
  fi
  sleep 0.5
done
