#!/bin/sh
set -eu

PROJECT="ShowMyIP.xcodeproj"
SCHEME="ShowMyIP"
BUILD_DIR="build"
DERIVED_DATA="$BUILD_DIR/DerivedData"
APP="$DERIVED_DATA/Build/Products/Release/ShowMyIP.app"
STAGING="$BUILD_DIR/dmg"
DMG="$BUILD_DIR/ShowMyIP.dmg"

rm -rf "$BUILD_DIR"

xcodebuild build \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration Release \
    -destination "generic/platform=macOS" \
    -derivedDataPath "$DERIVED_DATA" \
    -quiet

codesign --verify --deep --strict "$APP"

mkdir -p "$STAGING"
cp -R "$APP" "$STAGING/"
ln -s /Applications "$STAGING/Applications"

hdiutil create -volname "Show My IP" -srcfolder "$STAGING" -ov -format UDZO "$DMG" >/dev/null
(cd "$BUILD_DIR" && shasum -a 256 ShowMyIP.dmg > ShowMyIP.dmg.sha256)

VERSION=$(defaults read "$PWD/$APP/Contents/Info" CFBundleShortVersionString)
echo "Built Show My IP $VERSION"
echo "  $DMG"
echo "  $DMG.sha256"
