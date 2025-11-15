#!/bin/bash

# Auto-increment build number using PlistBuddy
# Add this as a Run Script Phase in Xcode build phases (before "Copy Bundle Resources")

set -e

# Path to Info.plist in source directory
INFO_PLIST="${PROJECT_DIR}/${INFOPLIST_FILE}"

# Verify the Info.plist exists
if [ ! -f "${INFO_PLIST}" ]; then
    echo "error: Info.plist not found at ${INFO_PLIST}"
    exit 1
fi

echo "📝 Incrementing build number in ${INFOPLIST_FILE}"

# Get the current build number
CURRENT_BUILD=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${INFO_PLIST}" 2>/dev/null || echo "0")

# Increment it
NEW_BUILD=$((CURRENT_BUILD + 1))

# Update the Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${NEW_BUILD}" "${INFO_PLIST}"

# Also ensure CFBundleShortVersionString exists (marketing version)
VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "${INFO_PLIST}" 2>/dev/null || echo "")

if [ -z "${VERSION}" ]; then
    echo "⚠️  CFBundleShortVersionString not found, setting to 1.0"
    /usr/libexec/PlistBuddy -c "Add :CFBundleShortVersionString string 1.0" "${INFO_PLIST}" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString 1.0" "${INFO_PLIST}"
fi

echo "✅ Build number incremented: ${CURRENT_BUILD} → ${NEW_BUILD}"
echo "   Version: ${VERSION} (${NEW_BUILD})"
