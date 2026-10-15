#!/bin/bash
# Checks Virtus without Xcode:
#   1. type-checks the iOS app and the widget extension against the iOS SDK (as Mac Catalyst),
#   2. lints the project file, Info.plists and entitlements,
#   3. builds and runs the self-test (library, daily order, pins, streak, widget plan) and renders the widgets + icon,
#   4. renders the app's screens to one PNG.
set -euo pipefail
cd "$(dirname "$0")/.."
OUT=${1:-build/selftest}
mkdir -p "$OUT"
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
SDK=$(xcrun --show-sdk-path 2>/dev/null || echo /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk)

# The Command Line Tools ship two module maps that both define SwiftBridging; hide the stale one.
FLAGS=()
STALE=/Library/Developer/CommandLineTools/usr/include/swift/module.modulemap
if [[ -f "$STALE" && -f /Library/Developer/CommandLineTools/usr/include/swift/bridging.modulemap ]]; then
  : > "$TMP/empty.modulemap"
  cat > "$TMP/overlay.yaml" <<YAML
{ "version": 0, "case-sensitive": "false", "roots": [ { "type": "directory",
  "name": "/Library/Developer/CommandLineTools/usr/include/swift",
  "contents": [ { "type": "file", "name": "module.modulemap", "external-contents": "$TMP/empty.modulemap" } ] } ] }
YAML
  FLAGS+=(-vfsoverlay "$TMP/overlay.yaml" -Xcc -ivfsoverlay -Xcc "$TMP/overlay.yaml")
fi
IOS=(-sdk "$SDK" -target arm64-apple-ios18.0-macabi -swift-version 5 -parse-as-library
     -Fsystem "$SDK/System/iOSSupport/System/Library/Frameworks" -I "$SDK/System/iOSSupport/usr/lib/swift")

echo "== iOS app (type-check)"
swiftc -typecheck "${IOS[@]}" "${FLAGS[@]}" -module-name Virtus \
  Shared/*.swift $(find Virtus -name '*.swift')
echo "== Widget extension (type-check)"
swiftc -typecheck "${IOS[@]}" "${FLAGS[@]}" -module-name VirtusWidgetExtension \
  Shared/*.swift VirtusWidget/*.swift

echo "== Project files"
plutil -lint Virtus.xcodeproj/project.pbxproj Virtus/Info.plist VirtusWidget/Info.plist \
  Entitlements/*.entitlements >/dev/null
for json in $(find Virtus/Assets.xcassets -name Contents.json); do python3 -m json.tool "$json" >/dev/null; done
python3 - <<'PY'
import glob, re, sys
pbx = open("Virtus.xcodeproj/project.pbxproj").read()
ok = True
for target, folders in {"Virtus": ["Virtus", "Shared"], "VirtusWidgetExtension": ["VirtusWidget", "Shared"]}.items():
    mains = [f for d in folders for f in glob.glob(f"{d}/**/*.swift", recursive=True) if re.search(r"^@main", open(f).read(), re.M)]
    if len(mains) != 1:
        print(f"{target}: expected one @main, found {mains}"); ok = False
for f in ["Virtus/Info.plist", "VirtusWidget/Info.plist"] + glob.glob("Entitlements/*.entitlements"):
    for ident in re.findall(r"group\.[^<]+", open(f).read()):
        if ident != "group.$(VIRTUS_ID_PREFIX).Virtus":
            print(f"{f}: unexpected identifier {ident}"); ok = False
if pbx.count("/* Portraits */") < 4:
    print("Portraits folder must be in the main group and both targets"); ok = False
for setting in ["VIRTUS_ID_PREFIX = ", "Entitlements/Virtus.entitlements", "Entitlements/VirtusWidget.entitlements", "SDKROOT = iphoneos"]:
    if setting not in pbx:
        print(f"project is missing {setting}"); ok = False
sys.exit(0 if ok else 1)
PY
echo "ok"

echo "== Self-test"
swiftc -swift-version 5 -target arm64-apple-macos14.0 "${FLAGS[@]}" -module-name VirtusSelfTest \
  Shared/*.swift Virtus/Model/*.swift Tools/selftest/main.swift -o "$TMP/selftest"
"$TMP/selftest" "$OUT"
cp "$OUT/AppIcon.png" Virtus/Assets.xcassets/AppIcon.appiconset/AppIcon.png
cp Portraits/*.jpg Portraits/*.png "$OUT/portraits/" 2>/dev/null || true
echo "   $(find Portraits -maxdepth 1 \( -name '*.jpg' -o -name '*.jpeg' -o -name '*.png' \) | wc -l | tr -d ' ') real portraits in Portraits/"

echo "== Screens (Mac Catalyst render)"
swiftc "${IOS[@]/-parse-as-library/}" "${FLAGS[@]}" -module-name VirtusScreens \
  Shared/*.swift $(find Virtus -name '*.swift' ! -name VirtusApp.swift) \
  Tools/screens/main.swift -o "$TMP/screens"
"$TMP/screens" "$OUT/screens.png"
"$TMP/screens" --store build/store
"$TMP/screens" --header build/store/header.png
"$TMP/screens" --preview build/preview
if command -v ffmpeg >/dev/null; then Tools/preview.sh build/preview build/store/preview-6.9.mp4; else echo "   (ffmpeg not installed: app preview video skipped)"; fi
