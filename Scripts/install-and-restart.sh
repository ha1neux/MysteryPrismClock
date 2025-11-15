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

# Copy the new build to the installation directory
echo -e "📥 Installing screensaver..."
cp -R "${BUILT_PRODUCT_PATH}" "${INSTALLED_SAVER}"

# Verify installation
if [ -d "${INSTALLED_SAVER}" ]; then
    echo -e "✅ Screensaver installed successfully!"
    echo -e "📁 Location: ${INSTALLED_SAVER}"
else
    echo -e "❌ Installation failed"
    exit 1
fi

# Touch the screensaver to update its modification date
# This can help the system recognize it's been updated
touch "${INSTALLED_SAVER}"

# Optional: Refresh the screensaver list cache
# This kills the preferences cache to force a refresh
defaults read com.apple.screensaver > /dev/null 2>&1 || true

echo -e "🎉 Screensaver installed and ready to use!"

exit 0
