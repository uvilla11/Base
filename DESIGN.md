# Base — Design System

Mood: **machinist's instrument — cold precision, one warm dial.**
Scene: splitting a bill at a dim restaurant table. Dark-first; light mode fully supported.

## Color (OKLCH → sRGB, semantic assets in Assets.xcassets)

| Role | Dark | Light | Asset name |
|---|---|---|---|
| Background | `#110C0E` | `#F7F4F5` | `BaseBackground` |
| Key surface | `#241D20` | `#EAE5E7` | `KeySurface` |
| Key raised (operators row) | `#342B2F` | `#DED7DA` | `KeySurfaceRaised` |
| Ink (primary text) | `#F5F0F2` | `#1E191B` | `InkPrimary` |
| Muted (secondary text) | `#A49C9F` | `#686164` | `InkMuted` |
| Accent (rose) | `#F072B3` | `#DB589E` | `AccentColor` |
| Accent pressed | `#BC3181` | `#BC3181` | `AccentDeep` |
| Positive | `#3FB171` | `#2E9A5F` | `PositiveGreen` |

Strategy: **restrained** — tinted rose-neutrals + one rose accent carrying every
interactive emphasis (operators, equals, active tab, sliders). No second accent.

## Typography

- System font (SF Pro) only. Display numerals: `.system(size:, weight: .light, design: .rounded)` — rounded for the friendly-instrument feel.
- Display: 56–72pt light rounded, monospaced digits for stable layout.
- Keys: 28pt medium rounded.
- Body/labels: system defaults, `.secondary` handled by `InkMuted`.

## Shape & spacing

- Key corner radius: continuous 16. Cards: 16. Pills (tip chips): capsule.
- Keypad gutter: 10pt. Screen margins: 16pt.
- No borders + big shadows. Elevation via surface color steps only.

## Motion

- Springs only: `.snappy` for key feedback, `.smooth` for tab/content transitions.
- `contentTransition(.numericText())` on all changing numbers.
- Matched-geometry rose pill for the tab switcher.
- Every animation honors Reduce Motion (SwiftUI handles; no custom timers).

## Haptics

Silent app — haptics are the sound design:
- Digit: light impact (0.7)
- Operator: medium impact
- Equals / meld: success notification
- Error: error notification
- Swap units: rigid impact

## Voice

Labels are single words. No exclamation marks. Errors are calm: "Can't divide by zero."
