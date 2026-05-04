#!/bin/bash
set -euo pipefail

NAME="TodoMenuBar"
APP_DIR="$NAME.app"
BUNDLE_ID="com.local.todomenubar"
VERSION="${VERSION:-1.0.2}"

cd "$(dirname "$0")"

echo "Building $NAME (release)..."
swift build -c release

echo "Creating $APP_DIR bundle..."
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

cp ".build/release/$NAME" "$APP_DIR/Contents/MacOS/$NAME"

cat > "$APP_DIR/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/property-list-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$NAME</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleName</key>
    <string>$NAME</string>
    <key>CFBundleDisplayName</key>
    <string>Todo Menu Bar</string>
    <key>CFBundleVersion</key>
    <string>$VERSION</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

echo "Ad-hoc code signing..."
codesign --force --deep --sign - \
    --options runtime \
    --identifier "$BUNDLE_ID" \
    "$APP_DIR"

codesign --verify --deep --strict --verbose=2 "$APP_DIR" 2>&1 | sed 's/^/   /'

ZIP_NAME="$NAME-$VERSION.zip"
echo "Creating $ZIP_NAME..."
rm -f "$ZIP_NAME"
ditto -c -k --keepParent "$APP_DIR" "$ZIP_NAME"

echo ""
echo "Done. $APP_DIR is ready."
echo "Run:        open $APP_DIR"
echo "Install:    cp -R $APP_DIR /Applications/"
