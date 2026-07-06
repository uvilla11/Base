#!/bin/bash
# capture_screenshots.sh — Takes App Store screenshots across all tabs and devices.
set -e

export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
PROJ="/Users/uvilla/Desktop/Base_ iOS_App"
OUT="$PROJ/Metadata/screenshots"
mkdir -p "$OUT"

# Resize icon to Apple's required 1024x1024
sips -z 1024 1024 "$PROJ/Base/Assets.xcassets/AppIcon.appiconset/icon-1024.png" --out "$OUT/icon-1024.png" &>/dev/null

DEVICE_IDS=(
    "D530FAF3-E46B-4590-8490-F1427C4C28A3:iphone17"
    "2232CB5A-968D-43C9-AEFA-AD6126E2C4F6:pro_max"
)

take_screenshots() {
    local device_id=$1 label=$2
    xcrun simctl boot "$device_id" 2>/dev/null || true
    xcrun simctl ui "$device_id" appearance dark

    for tab_idx in 0 1 2; do
        tab_name="calculator"
        case $tab_idx in
            1) tab_name="converter" ;;
            2) tab_name="tip" ;;
        esac

        # Modify default tab in ContentView
        sed -i '' "s/@State private var selectedTab: Tab = .*/@State private var selectedTab: Tab = .$tab_name/" "$PROJ/Base/ContentView.swift"

        xcodebuild -project "$PROJ/Base.xcodeproj" -scheme Base -sdk iphonesimulator -destination "id=$device_id" build &>/dev/null
        APP=$(find ~/Library/Developer/Xcode/DerivedData/Base-*/Build/Products/Debug-iphonesimulator -name "Base.app" -maxdepth 1 | head -1)
        xcrun simctl terminate "$device_id" com.basecalc.app 2>/dev/null
        xcrun simctl install "$device_id" "$APP"
        xcrun simctl launch "$device_id" com.basecalc.app &>/dev/null
        sleep 3

        xcrun simctl io "$device_id" screenshot "$OUT/${label}_${tab_name}.png" 2>/dev/null
        echo "  ✅ $label $tab_name"
    done
}

for entry in "${DEVICE_IDS[@]}"; do
    IFS=":" read -r device_id label <<< "$entry"
    echo "Capturing $label ($device_id)…"
    xcrun simctl boot "$device_id" 2>/dev/null || true
    take_screenshots "$device_id" "$label"
done

# Restore default tab to calculator
sed -i '' 's/@State private var selectedTab: Tab = .*/@State private var selectedTab: Tab = .calculator/' "$PROJ/Base/ContentView.swift"

echo ""
echo "Screenshots saved to $OUT"
ls -1 "$OUT"/*.png
