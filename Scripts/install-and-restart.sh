#!/bin/bash

# Exit on error
set -e

echo -e "🔧 Post-Build: Installing and Restarting Screensaver"

# Get the built product path
BUILT_PRODUCT_PATH="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.${WRAPPER_EXTENSION}"

echo -e "📦 Built product: ${BUILT_PRODUCT_PATH}"

# Verify the build exists
if [ ! -d "${BUILT_PRODUCT_PATH}" ]; then
    echo -e "❌ Error: Built product not found at ${BUILT_PRODUCT_PATH}"
    exit 1
fi

# Define installation directory (user screensavers)
INSTALL_DIR="${HOME}/Library/Screen Savers"
INSTALLED_SAVER="${INSTALL_DIR}/${PRODUCT_NAME}.${WRAPPER_EXTENSION}"

echo -e "📍 Installation directory: ${INSTALL_DIR}"

# Create the directory if it doesn't exist
mkdir -p "${INSTALL_DIR}"

# Kill all running screensaver processes
echo -e "🛑 Killing all screensaver processes..."

# Kill the System Preferences/Settings process if it's open (to release file locks)
pkill -x "System Preferences" 2>/dev/null || true
pkill -x "System Settings" 2>/dev/null || true

# Kill the legacyScreenSaver process (this is what actually runs screensavers)
pkill -x "legacyScreenSaver" 2>/dev/null || true

# Kill the ScreenSaverEngine process
pkill -x "ScreenSaverEngine" 2>/dev/null || true

# Kill any process that might have loaded our specific screensaver
# This uses the product name to be more specific
pkill -f "${PRODUCT_NAME}" 2>/dev/null || true

# Wait a moment for processes to fully terminate
sleep 0.5

echo -e "✅ All screensaver processes terminated"

# Remove old installation if it exists
if [ -d "${INSTALLED_SAVER}" ]; then
    echo -e "🗑️  Removing old installation..."
    rm -rf "${INSTALLED_SAVER}"
fi

# Copy the new build to the installation directory using ditto (preserves code signatures)
echo -e "📥 Installing screensaver..."
ditto "${BUILT_PRODUCT_PATH}" "${INSTALLED_SAVER}"

# Verify installation
if [ -d "${INSTALLED_SAVER}" ]; then
    echo -e "✅ Screensaver installed successfully!"
    echo -e "📁 Location: ${INSTALLED_SAVER}"
else
    echo -e "❌ Installation failed"
    exit 1
fi

# Sign the installed bundle
# (This script runs before the built-in CodeSign step in the build phases,
# so we need to explicitly sign the installed copy)
echo -e "✍️  Signing installed screensaver..."

# Get the code sign identity - prefer the expanded one if available
SIGN_IDENTITY="${EXPANDED_CODE_SIGN_IDENTITY:-${CODE_SIGN_IDENTITY}}"

# Get entitlements file if it exists
ENTITLEMENTS_FILE="${CODE_SIGN_ENTITLEMENTS}"
if [ -n "${ENTITLEMENTS_FILE}" ] && [ -f "${PROJECT_DIR}/${ENTITLEMENTS_FILE}" ]; then
    codesign --force \
             --sign "${SIGN_IDENTITY}" \
             --timestamp \
             --entitlements "${PROJECT_DIR}/${ENTITLEMENTS_FILE}" \
             "${INSTALLED_SAVER}"
else
    codesign --force \
             --sign "${SIGN_IDENTITY}" \
             --timestamp \
             "${INSTALLED_SAVER}"
fi

if [ $? -eq 0 ]; then
    echo -e "✅ Screensaver signed successfully"
else
    echo -e "⚠️  Warning: Could not sign installed screensaver"
fi

# Touch the screensaver to update its modification date
# This can help the system recognize it's been updated
touch "${INSTALLED_SAVER}"

# Optional: Refresh the screensaver list cache
# This kills the preferences cache to force a refresh
defaults read com.apple.screensaver > /dev/null 2>&1 || true

echo -e "🎉 Screensaver installed and ready to use!"

exit 0
