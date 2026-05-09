#!/usr/bin/env bash
# Build a release-mode QuickThoughts executable and wrap it in a proper
# macOS .app bundle (with Info.plist, LSUIElement so it stays out of the Dock,
# and an ad-hoc code signature). Output goes to dist/Quick Thoughts.app.
#
# This avoids needing an Xcode project file — pure SPM + a few cp + plist write.
set -euo pipefail

APP_NAME="QuickThoughts"
DISPLAY_NAME="Quick Thoughts"
BUNDLE_ID="com.zyb.QuickThoughts"
VERSION="${VERSION:-0.1.0}"
MIN_MACOS="13.0"

cd "$(dirname "$0")/.."

echo "==> swift build -c release"
swift build -c release

BIN_PATH=".build/release/$APP_NAME"
if [[ ! -f "$BIN_PATH" ]]; then
    echo "error: built binary not found at $BIN_PATH" >&2
    exit 1
fi

APP_DIR="dist/$DISPLAY_NAME.app"
echo "==> rebuilding $APP_DIR"
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

cp "$BIN_PATH" "$APP_DIR/Contents/MacOS/$APP_NAME"

# SPM places package resources (e.g. KeyboardShortcuts' Localization
# .strings files) next to the binary as <package>_<target>.bundle. We need
# them inside Contents/Resources for runtime lookups to keep working
# once the executable lives inside our .app.
shopt -s nullglob
for resource_bundle in .build/release/*.bundle; do
    cp -R "$resource_bundle" "$APP_DIR/Contents/Resources/"
done
shopt -u nullglob

cat > "$APP_DIR/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$DISPLAY_NAME</string>
    <key>CFBundleDisplayName</key>
    <string>$DISPLAY_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundleVersion</key>
    <string>$VERSION</string>
    <key>LSMinimumSystemVersion</key>
    <string>$MIN_MACOS</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSSupportsAutomaticTermination</key>
    <false/>
    <key>NSSupportsSuddenTermination</key>
    <false/>
</dict>
</plist>
EOF

echo "==> codesign --force --deep --sign - (ad-hoc)"
codesign --force --deep --sign - "$APP_DIR"

echo
echo "✓ Bundled: $APP_DIR"
echo "  Install:  cp -R \"$APP_DIR\" /Applications/"
echo "  Or run:   make install"
