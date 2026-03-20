#!/bin/bash
# Patches simple-bar-bottom with custom index.jsx and separate config
BOTTOM_DIR="$HOME/Library/Application Support/Übersicht/widgets/simple-bar-bottom"

# Fix script paths (simple-bar -> simple-bar-bottom)
find "$BOTTOM_DIR" \( -name '*.js' -o -name '*.jsx' \) \
    -exec sed -i '' 's|simple-bar/lib/scripts|simple-bar-bottom/lib/scripts|g' {} +

# Reset settings.js to upstream before patching (idempotent)
cd "$BOTTOM_DIR" && git checkout lib/settings.js 2>/dev/null; cd -

# Use separate config file
sed -i '' 's|~/.simplebarrc|~/.simplebarrc-bottom|g' "$BOTTOM_DIR/lib/settings.js"

# Use separate localStorage key
sed -i '' 's|simple-bar-settings|simple-bar-bottom-settings|g' "$BOTTOM_DIR/lib/settings.js"

# Write custom index.jsx with bottom bar layout
cat > "$BOTTOM_DIR/index.jsx" << 'INDEXEOF'
import * as Uebersicht from "uebersicht";
import SimpleBarContextProvider from "./lib/components/simple-bar-context.jsx";
import * as Sound from "./lib/components/data/sound.jsx";
import * as Mic from "./lib/components/data/mic.jsx";
import * as Wifi from "./lib/components/data/wifi.jsx";
import * as Cpu from "./lib/components/data/cpu.jsx";
import * as Gpu from "./lib/components/data/gpu.jsx";
import * as Memory from "./lib/components/data/memory.jsx";
import * as Netstats from "./lib/components/data/netstats.jsx";
import * as Utils from "./lib/utils";
import * as Settings from "./lib/settings";

const { React } = Uebersicht;

export const refreshFrequency = false;
export const className = `
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  top: unset;
`;

Settings.init();
const settings = Settings.get();

const { shell, aerospacePath = "/opt/homebrew/bin/aerospace" } = settings.global;
export const command = `${shell} simple-bar-bottom/lib/scripts/init-aerospace.sh ${aerospacePath}`;

function BatteryWidget() {
  const [state, setState] = React.useState(null);

  const getBattery = React.useCallback(async () => {
    try {
      const [percentage, status, caffeinate] = await Promise.all([
        Uebersicht.run("pmset -g batt | grep -Eo '[0-9]+%' | head -1 | tr -d '%'"),
        Uebersicht.run("pmset -g batt | head -1 | grep -q 'AC Power' && echo 'AC' || echo 'Batt'"),
        Uebersicht.run("pgrep caffeinate || echo ''"),
      ]);
      setState({
        percentage: parseInt(percentage, 10),
        charging: status.trim() === 'AC',
        caffeinate: caffeinate.trim(),
      });
    } catch (e) {
      console.error('BatteryWidget error:', e);
    }
  }, []);

  React.useEffect(() => {
    getBattery();
    const interval = setInterval(getBattery, 10000);
    return () => clearInterval(interval);
  }, [getBattery]);

  if (!state) return null;

  const { percentage, charging, caffeinate } = state;
  const isLow = !charging && percentage < 20;

  const fillStyle = {
    position: 'absolute',
    top: 1, left: 1,
    width: 'calc(100% - 2px)',
    height: 'calc(100% - 2px)',
    backgroundColor: isLow ? 'var(--red)' : 'currentColor',
    borderRadius: 2,
    transform: `scaleX(${percentage >= 100 ? 1 : percentage < 10 ? '0.0' + percentage : '0.' + percentage})`,
    transformOrigin: 'left center',
  };

  const toggleCaffeinate = async (e) => {
    Utils.clickEffect(e);
    if (caffeinate) {
      await Uebersicht.run("pkill -f caffeinate");
    } else {
      Uebersicht.run("caffeinate &");
    }
    getBattery();
  };

  return (
    <div
      className={`data-widget data-widget--clickable${caffeinate ? ' battery--caffeinate' : ''}`}
      onClick={toggleCaffeinate}
    >
      <div className="battery__icon">
        <div className="battery__icon-inner">
          <div style={fillStyle} />
        </div>
      </div>
      {charging ? '⚡ ' : ''}{percentage}%
    </div>
  );
}

function DiskWidget() {
  const [state, setState] = React.useState(null);

  const getDisk = React.useCallback(async () => {
    try {
      const result = await Uebersicht.run("df -H / | awk 'NR==2 {print $4, $5}'");
      const [free, usedPct] = result.trim().split(' ');
      setState({ free, usedPct });
    } catch (e) {
      console.error('DiskWidget error:', e);
    }
  }, []);

  React.useEffect(() => {
    getDisk();
    const interval = setInterval(getDisk, 30000);
    return () => clearInterval(interval);
  }, [getDisk]);

  if (!state) return null;

  return (
    <div className="data-widget">
      <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor" style={{ marginRight: 7 }}>
        <path d="M22 12H2" /><path d="M5.45 5.11L2 12v6a2 2 0 002 2h16a2 2 0 002-2v-6l-3.45-6.89A2 2 0 0016.76 4H7.24a2 2 0 00-1.79 1.11z" />
      </svg>
      {state.free}
    </div>
  );
}

export function render({ output }) {
  const data = output ? Utils.parseJson(Utils.cleanupOutput(output)) : null;
  const displays = data?.displays || [];
  const SIPDisabled = data?.SIP !== "System Integrity Protection status: enabled.";

  return (
    <SimpleBarContextProvider
      initialSettings={settings}
      displays={displays}
      SIPDisabled={SIPDisabled}
    >
      <div className="simple-bar simple-bar--no-color-in-data" style={{ position: 'static' }}>
        <div className="simple-bar__data" style={{ marginLeft: 0 }}>
          <BatteryWidget />
          <DiskWidget />
          <Mic.Widget />
          <Sound.Widget />
          <Wifi.Widget />
        </div>
        <div className="simple-bar__data">
          <Cpu.Widget />
          <Gpu.Widget />
          <Memory.Widget />
          <Netstats.Widget />
        </div>
      </div>
    </SimpleBarContextProvider>
  );
}
INDEXEOF
