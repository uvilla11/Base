#!/bin/bash
# setup-deployment.sh — One-time setup for App Store deployment pipeline.
# Run this once after cloning the repo on a Mac with Xcode installed.
set -e

echo "==> Base App — Deployment Setup"
echo ""

# ── 1. Verify Xcode ──
if ! xcodebuild -version &>/dev/null; then
    echo "❌ Xcode not found. Install Xcode 26+ first."
    exit 1
fi
echo "✅ Xcode $(xcodebuild -version | head -1)"

# ── 2. Install Fastlane ──
if which fastlane &>/dev/null; then
    echo "✅ Fastlane $(fastlane --version | head -1)"
else
    echo "Installing Fastlane…"
    sudo gem install fastlane 2>/dev/null || gem install fastlane --user-install
    if which fastlane &>/dev/null; then
        echo "✅ Fastlane installed"
    else
        echo "⚠️  Fastlane install failed. Run: gem install fastlane --user-install"
    fi
fi

# ── 3. Certificates (Fastlane Match) ──
echo ""
echo "==> Code Signing (Fastlane Match)"
echo ""

if [ ! -f fastlane/Matchfile ]; then
    echo "⚠️  Matchfile not found. Run: fastlane match init"
    echo "   Then: fastlane match development"
    echo "   Then: fastlane match appstore"
else
    echo "Matchfile exists at fastlane/Matchfile"
    echo "To generate certificates, set these env vars:"
    echo "  export MATCH_GIT_URL=git@github.com:uvilla11/Base-certs.git"
    echo "  export MATCH_PASSWORD=<your-password>"
    echo "Then run: fastlane match development"
    echo "     and: fastlane match appstore"
fi

# ── 4. App Store Connect ──
echo ""
echo "==> App Store Connect"
echo ""
echo "1. Create the app listing at https://appstoreconnect.apple.com"
echo "   - Name: Base"
echo "   - Bundle ID: com.basecalc.app"
echo "   - SKU: BASE001"
echo "   - Price: Free (tip-jar IAP)"
echo "2. Generate API key: Users → API Keys → Generate"
echo "   Save the key file, issuer ID, and key ID."
echo "3. Set GitHub Actions secrets:"
echo "   - APP_STORE_CONNECT_API_KEY (path to .p8 file)"
echo "   - MATCH_PASSWORD"
echo "   - MATCH_GIT_URL"

# ── 5. Screenshots ──
echo ""
echo "==> Screenshots"
echo ""
SCREENSHOTS="Metadata/screenshots/"
if [ -d "$SCREENSHOTS" ] && [ "$(ls -A "$SCREENSHOTS" 2>/dev/null)" ]; then
    echo "✅ Screenshots found in $SCREENSHOTS:"
    ls -1 "$SCREENSHOTS"*.png 2>/dev/null | while read f; do
        SIZE=$(sips -g pixelWidth -g pixelHeight "$f" 2>/dev/null | grep -E "pixel" | tr '\n' ' ' | awk '{print $2"x"$4}')
        echo "   $(basename "$f") — $SIZE"
    done
else
    echo "⚠️  No screenshots yet. Run: bash Scripts/capture_screenshots.sh"
fi

# ── 6. Privacy Policy ──
echo ""
echo "==> Privacy Policy"
echo ""
echo "Privacy policy is at Metadata/privacy-policy.html"
echo "Host it at one of:"
echo "  • https://uvilla11.github.io/Base/  (make repo public → enable Pages → gh-pages branch)"
echo "  • Netlify (drag-and-drop the HTML file)"
echo "  • Any static hosting"
echo "Then update Metadata/app_store.json → privacyURL"

# ── 7. Deploy ──
echo ""
echo "==> Deploy to TestFlight"
echo ""
echo "  fastlane deploy"
echo ""
echo "==> Deploy to App Store"
echo ""
echo "  fastlane release"
echo ""
echo "Done. 🚀"
