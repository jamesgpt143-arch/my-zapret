#!/bin/sh

echo "==========================================="
echo " Zapret OpenWrt - Smart Unli Data Installer"
echo "==========================================="

echo "Detecting router architecture..."
ARCH=$(opkg print-architecture | awk '{print $2}' | grep -E -v 'all|noarch' | head -n 1)

if [ -z "$ARCH" ]; then
    echo "Error: Could not detect architecture"
    exit 1
fi

echo "Architecture detected: $ARCH"

echo "Fetching latest release from GitHub..."
API_URL="https://api.github.com/repos/jamesgpt143-arch/my-zapret/releases/latest"

DOWNLOAD_URL=$(curl -sL "$API_URL" | grep -o '"browser_download_url": "[^"]*"' | grep "_${ARCH}.zip" | cut -d'"' -f4 | head -n 1)

if [ -z "$DOWNLOAD_URL" ]; then
    echo "Error: Could not find a pre-compiled package for architecture $ARCH"
    echo "Please check https://github.com/jamesgpt143-arch/my-zapret/releases to make sure the build has finished."
    exit 1
fi

echo "Downloading package..."
cd /tmp
rm -rf zapret_temp
mkdir -p zapret_temp
curl -sL "$DOWNLOAD_URL" -o zapret_temp/zapret.zip

echo "Extracting..."
cd zapret_temp
unzip -q zapret.zip

echo "Installing packages..."
opkg update
opkg install *.ipk

echo "Cleaning up..."
cd /tmp
rm -rf zapret_temp

echo "==========================================="
echo "Zapret Installation Complete!"
echo "You can now go to OpenWrt LuCI Web UI to configure it."
echo "==========================================="
