#!/bin/bash
set -e

# Configuration
APP_NAME="Citman"
BUILD_DIR=".build/release"
APP_BUNDLE="${APP_NAME}.app"
INFO_PLIST="Sources/Citman/Info.plist"

echo "🚀 Building ${APP_NAME}..."
swift build -c release "$@"

# Create the App Bundle Structure
echo "📂 Creating App Bundle..."
rm -rf "${APP_BUNDLE}"
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

# Copy Binary
echo "dg Copying Binary..."
cp "${BUILD_DIR}/${APP_NAME}" "${APP_BUNDLE}/Contents/MacOS/"

# Copy Info.plist (Crucial for File Associations)
echo "📝 Copying Info.plist..."
cp "${INFO_PLIST}" "${APP_BUNDLE}/Contents/Info.plist"

# Copy Icon
echo "🖼️ Copying Icon..."
cp "Sources/Citman/AppIcon.icns" "${APP_BUNDLE}/Contents/Resources/AppIcon.icns"

# Set Executable Permissions
chmod +x "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"

# Remove extended attributes that might cause quarantine issues (optional but good for local builds)
xattr -cr "${APP_BUNDLE}"

# Force LaunchServices to re-register the app
echo "🔄 Registering with LaunchServices..."
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "${APP_BUNDLE}"

echo "✅ Done! You can now run the app: open ${APP_BUNDLE}"
echo "   Or drag '${APP_BUNDLE}' to your Applications folder."
