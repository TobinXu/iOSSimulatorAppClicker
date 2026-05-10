#!/bin/bash
#
# iOS Simulator: open Temu and click "我的" (My/Profile tab)
# Usage: bash temu_click.sh [device_udid]
#
set -euo pipefail

SIMCTL="/Applications/Xcode.app/Contents/Developer/usr/bin/simctl"
TEMU_BUNDLE="com.einnovation.temu.beta"

# --- helpers ---
find_device() {
    # prefer the arg, then the first booted iPhone, then the first available iPhone
    local name="${1:-}"
    if [ -n "$name" ]; then
        echo "$name"
    else
        # pick a booted iPhone
        local booted
        booted=$("$SIMCTL" list devices booted -j 2>/dev/null | python3 -c "
import json,sys
d=json.load(sys.stdin)
devs=[(k,v['udid']) for k,v in d.get('devices',{}).items() for vv in v if 'iPhone' in k and vv.get('state')=='Booted']
print(devs[0][1] if devs else '')
" 2>/dev/null)
        if [ -n "$booted" ]; then
            echo "$booted"
        else
            # find the first available iPhone (latest OS)
            "$SIMCTL" list devices available -j 2>/dev/null | python3 -c "
import json,sys
d=json.load(sys.stdin)
for rt in sorted(d.get('devices',{}).keys(), reverse=True):
    devs=[(v['udid'],v['name']) for v in d['devices'][rt] if 'iPhone' in v.get('name','')]
    if devs: print(devs[0][0]); break
"
        fi
    fi
}

UDID=$(find_device "${1:-}")
if [ -z "$UDID" ]; then
    echo "No iPhone simulator found."
    exit 1
fi

echo "Device UDID: $UDID"

# 1. Boot if needed
STATE=$("$SIMCTL" list devices -j 2>/dev/null | python3 -c "
import json,sys
d=json.load(sys.stdin)
for rt,devs in d.get('devices',{}).items():
    for v in devs:
        if v.get('udid')=='$UDID':
            print(v.get('state','unknown'))
            sys.exit(0)
print('unknown')
")
echo "State: $STATE"

if [ "$STATE" != "Booted" ]; then
    echo "Booting simulator..."
    "$SIMCTL" boot "$UDID"
    # wait for boot to finish
    for i in $(seq 1 30); do
        BT=$("$SIMCTL" list devices -j | python3 -c "
import json,sys
d=json.load(sys.stdin)
for rt,devs in d.get('devices',{}).items():
    for v in devs:
        if v.get('udid')=='$UDID':
            print(v.get('state',''))
            sys.exit(0)
")
        if [ "$BT" = "Booted" ]; then break; fi
        sleep 2
    done
    echo "Simulator booted."
fi

# Bring Simulator to front
open -a Simulator
sleep 3

# 2. Launch Temu
echo "Launching Temu..."
"$SIMCTL" launch "$UDID" "$TEMU_BUNDLE" 2>&1 || {
    echo "Failed to launch Temu. Is it installed?"
    echo ""
    echo "Install it via one of:"
    echo "  1. Build & run from Xcode"
    echo "  2. Drag the .app bundle into the simulator"
    echo "  3. xcrun simctl install $UDID /path/to/Temu.app"
    exit 1
}

# wait for app to launch & render
sleep 5

# 3. Tap "我的" tab (bottom, third tab of four)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Tapping 我的 tab..."

# Get front window position and click
python3 -c "
import subprocess
# Force Simulator to frontmost
subprocess.run(['osascript', '-e', '''
tell application \"System Events\"
    set simProcs to every process whose name is \"Simulator\"
    if (count of simProcs) > 0 then
        repeat with p in simProcs
            set frontmost of p to true
            exit repeat
        end repeat
        delay 1
    end if
end tell
'''], capture_output=True)

# Get front window position
pos = subprocess.run(['osascript', '-e', '''
tell application \"System Events\"
    tell process \"Simulator\"
        set simWin to front window
        set {winX, winY} to position of simWin
        set {winW, winH} to size of simWin
    end tell
    return (winX as text) + \" \" + (winY as text) + \" \" + (winW as text) + \" \" + (winH as text)
end tell
'''], capture_output=True, text=True)

winX, winY, winW, winH = [float(x) for x in pos.stdout.strip().split()]
# Calculate actual screen area inside the device bezel
screenLeft = winX + (winW * 0.08)
screenTop = winY + (winW * 0.09)
screenW = winW * 0.84
screenH = winH * 0.84
# \"我的\" is the third of four tabs at bottom, 50% width, 94% height
tapX = screenLeft + (screenW * 0.50)
tapY = screenTop + (screenH * 0.94)
print(f'\\nTapping at: x={tapX:.1f} y={tapY:.1f} (top-left window coordinates)')
# Call swift click tool
subprocess.run(['swift', f'{SCRIPT_DIR}/simclick.swift', str(tapX), str(tapY)])
"

echo "Done! Temu should be open on the 我的 page."
