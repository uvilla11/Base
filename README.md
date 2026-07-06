# Base

Personal number & unit Swiss-army-knife for iOS. Calculator, unit converter, and tip splitter — one clean screen, no ads, no account, no subscription.

[![CI](https://github.com/uvilla11/Base/actions/workflows/ci.yml/badge.svg)](https://github.com/uvilla11/Base/actions/workflows/ci.yml)

## Features

- **Calculator** with live result preview, history, Shunting-yard expression parser
- **Unit converter** for length, mass, volume, temperature, and currency
- **Tip splitter** with adjustable tip percentage and person count
- **Dark & light mode** with semantic color system (rose accent on tinted neutrals)
- **Haptic feedback** as the sound design — no audio assets needed
- **Zero dependencies** — SwiftUI, Foundation, CoreHaptics only
- **No account, no analytics, no ads, no subscription** — tip-jar supported

## Architecture

```
Base.xcodeproj/
├── Base/
│   ├── Models/          — Pure logic, no SwiftUI (CalculationEngine, UnitConversion, Expression, Theme, Haptics)
│   ├── ViewModels/      — @Observable state (CalculatorVM, UnitConverterVM)
│   ├── Views/           — SwiftUI layout only (CalculatorView, UnitConverterView, TipCalculatorView, HistoryView)
│   ├── BaseApp.swift    — @main entry point
│   ├── ContentView.swift — Tab switcher
│   ├── Assets.xcassets/ — Color sets, AppIcon
│   └── Info.plist
├── BaseTests/           — XCTest for CalculationEngine
├── Scripts/             — Self-check runner (no Xcode needed), icon renderer
├── fastlane/            — App Store deployment automation
└── .github/workflows/   — CI pipeline
```

Key design decisions (see [`DESIGN.md`](DESIGN.md) and [`PRODUCT.md`](PRODUCT.md) for full rationale):

- **Pure logic files never import SwiftUI.** `CalculationEngine`, `UnitConversion`, `Expression` — zero UI dependencies. Testable without a simulator.
- **One `@Observable` per concept.** `CalculatorVM` is the single source of truth for calculator state. No scattered `@State`.
- **UserDefaults over CoreData.** History ring buffer (max 50 entries) — trivially fits in JSON-encoded UserDefaults.
- **Flat conversion tables over `Measurement` API.** Faster, simpler, serializable.

## Development

### Prerequisites

- Xcode 26+ (iOS 17+ SDK)
- macOS 14+

### Build & Run

```bash
open Base.xcodeproj    # then press ⌘R
```

### Run logic self-check (no Xcode needed)

```bash
./Scripts/check.sh
```

24 engine assertions + 7 conversion checks. Runs in <2 seconds.

### Run unit tests

```bash
xcodebuild test -project Base.xcodeproj -scheme Base -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17'
```

## App Store

### Monetization

Free download with tip-jar in-app purchase ($0.99 / $2.99 / $4.99). No ads, no accounts, no subscription.

### Deployment

Uses [Fastlane](https://fastlane.tools) for App Store Connect upload.

```bash
cd fastlane
fastlane deploy       # Build + upload to TestFlight
fastlane release      # Build + upload to App Store
```

Required environment variables (set in GitHub Actions secrets):

| Variable | Purpose |
|---|---|
| `APP_STORE_CONNECT_API_KEY` | App Store Connect API key for auth |
| `MATCH_PASSWORD` | Password for encrypted signing certificates |
| `MATCH_GIT_URL` | Git repo URL for code signing (match) |

## Contributing

This is a solo project. PRs welcome for bug fixes. Feature requests → open an issue.

## License

MIT
