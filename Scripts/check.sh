#!/bin/sh
# Runs the pure-logic self-check (engine + unit conversions). No Xcode project needed.
set -e
DIR="$(cd "$(dirname "$0")/.." && pwd)"
TMP=$(mktemp -d)
cat "$DIR/Base/Models/CalculationEngine.swift" "$DIR/Base/Models/UnitConversion.swift" "$DIR/Scripts/logic_check.swift" > "$TMP/all.swift"
swift "$TMP/all.swift"
