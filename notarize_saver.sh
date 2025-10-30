#!/bin/bash

set -e

# Configuration - UPDATE THESE VALUES
DEVELOPER_ID="Developer ID Application: Bill Coderre (RUHYK57MF9)"
NOTARIZATION_KEYCHAIN_PROFILE="notarization-profile"

# Find the most recent build
DERIVED_DATA_PATH="$HOME/Library/Developer/Xcode/DerivedData"
PROJECT_BUILD_PATH=$(find "${DERIVED_DATA_PATH}" -name "MysteryPrismClock-*" -type d | head -1)

if [ -z "${PROJECT_BUILD_PATH}" ]; then
    echo "❌ Could not find DerivedData path for MysteryPrismClock"
    exit 1
fi

BUNDLE_PATH="${PROJECT_BUILD_PATH}/Build/Products/Release/MysteryPrism.saver"

echo "🔍 Starting signing, notarization, and stapling..."
echo "Bundle path: ${BUNDLE_PATH}"

# Verify bundle exists
if [ ! -d "${BUNDLE_PATH}" ]; then
    echo "❌ Bundle not found at ${BUNDLE_PATH}"
    echo "Available builds:"
    find "${PROJECT_BUILD_PATH}/Build/Products" -name "*.saver" 2>/dev/null || echo "No .saver bundles found"
    exit 1
fi

# Check current signature
echo "🔍 Current signature status:"
codesign -dv "${BUNDLE_PATH}" 2>&1

# Step 1: Sign for distribution
echo "✍️  Signing bundle for distribution..."
codesign --force \
         --verify \
         --verbose \
         --sign "${DEVELOPER_ID}" \
         --options runtime \
         --timestamp \
         "${BUNDLE_PATH}"

if [ $? -ne 0 ]; then
    echo "❌ Code signing failed"
    exit 1
fi

echo "✅ Bundle signed successfully"

# Step 2: Create a zip for notarization
BUNDLE_DIR="$(dirname "${BUNDLE_PATH}")"
BUNDLE_NAME="$(basename "${BUNDLE_PATH}" .saver)"
ZIP_PATH="${BUNDLE_DIR}/${BUNDLE_NAME}.zip"

echo "📦 Creating zip for notarization..."
cd "${BUNDLE_DIR}"
rm -f "${BUNDLE_NAME}.zip"
/usr/bin/ditto -c -k --keepParent "${BUNDLE_NAME}.saver" "${BUNDLE_NAME}.zip"

if [ ! -f "${ZIP_PATH}" ]; then
    echo "❌ Failed to create zip file"
    exit 1
fi

echo "✅ Zip created at ${ZIP_PATH}"

# Step 3: Submit for notarization
echo "🚀 Submitting for notarization..."
xcrun notarytool submit "${ZIP_PATH}" \
                       --keychain-profile "${NOTARIZATION_KEYCHAIN_PROFILE}" \
                       --wait

if [ $? -ne 0 ]; then
    echo "❌ Notarization failed"
    exit 1
fi

echo "✅ Notarization completed successfully"

# Step 4: Staple the notarization ticket
echo "📎 Stapling notarization ticket..."
xcrun stapler staple "${BUNDLE_PATH}"

if [ $? -ne 0 ]; then
    echo "❌ Stapling failed"
    exit 1
fi

echo "✅ Stapling completed successfully"

# Step 5: Final verification
echo "🔍 Final verification..."
codesign --verify --verbose=2 "${BUNDLE_PATH}"
xcrun stapler validate "${BUNDLE_PATH}"

echo "🎉 Bundle successfully signed, notarized, and stapled!"
echo "📁 Signed bundle location: ${BUNDLE_PATH}"

# Clean up zip file
rm -f "${ZIP_PATH}"
echo "🧹 Cleaned up temporary zip file"

echo "📦 Creating zip for distribution"
/usr/bin/ditto -c -k --keepParent "${BUNDLE_NAME}.saver" "${BUNDLE_NAME}.zip"
echo "🎉 Completed!"
