#!/bin/bash
set -euo pipefail

echo "Fetching latest Beeper version..."

# Get the latest download URL
LATEST_URL=$(curl -s -I "https://api.beeper.com/desktop/download/linux/x64/stable/com.automattic.beeper.desktop" | grep -i location | cut -d' ' -f2 | tr -d '\r')

echo "Latest URL: $LATEST_URL"

# Extract version and filename
FILENAME=$(basename "$LATEST_URL")
VERSION=$(echo "$FILENAME" | sed 's/Beeper-//' | sed 's/.AppImage//')

echo "Version: $VERSION"
echo "Downloading and calculating SHA256..."

# Download and calculate SHA256
SHA256=$(curl -s -L "$LATEST_URL" | sha256sum | cut -d' ' -f1)
SIZE=$(curl -s -I "$LATEST_URL" | grep -i content-length | cut -d' ' -f2 | tr -d '\r')

echo "SHA256: $SHA256"
echo "Size: $SIZE"

# Update the manifest
sed -i "s|url: https://beeper-desktop.download.beeper.com/builds/Beeper-.*\.AppImage|url: $LATEST_URL|" com.beeper.beepertexts.yml
sed -i "s|sha256: .*|sha256: $SHA256|" com.beeper.beepertexts.yml
sed -i "s|size: .*|size: $SIZE|" com.beeper.beepertexts.yml

# Update the release version in metainfo
sed -i "s|<release version=\".*\"|<release version=\"$VERSION\"|" com.beeper.beepertexts.metainfo.xml
sed -i "s|date=\".*\"|date=\"$(date +%Y-%m-%d)\"|" com.beeper.beepertexts.metainfo.xml

echo "Updated manifest with latest version $VERSION"
echo "You can now run: just build-flatpak"
