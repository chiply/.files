#!/bin/bash
# Patches simple-bar (top bar) to remove widgets moved to the bottom bar
TOP_DIR="$HOME/Library/Application Support/Übersicht/widgets/simple-bar"

python3 -c "
f = '$TOP_DIR/index.jsx'
with open(f) as fh:
    content = fh.read()

# Remove widgets that are now on the bottom bar
for widget in ['<Battery.Widget />', '<Mic.Widget />', '<Sound.Widget />', '<Wifi.Widget />',
               '<Cpu.Widget />', '<Gpu.Widget />', '<Memory.Widget />', '<Netstats.Widget />']:
    content = content.replace('          ' + widget + '\n', '')

with open(f, 'w') as fh:
    fh.write(content)
"
