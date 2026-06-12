#!/bin/sh

echo "==========================================="
echo " FlowVPN OpenWrt - Smart Unli Data Installer"
echo "==========================================="

echo "Detecting router architecture..."
ARCH=$(opkg print-architecture | awk '{print $2}' | grep -E -v 'all|noarch' | head -n 1)

if [ -z "$ARCH" ]; then
    echo "Error: Could not detect architecture"
    exit 1
fi

echo "Architecture detected: $ARCH"

echo "Fetching latest release from GitHub..."
TAG=$(curl -sI "https://github.com/jamesgpt143-arch/my-zapret/releases/latest" | grep -i '^location:' | awk -F '/' '{print $NF}' | tr -d '\r')

if [ -z "$TAG" ]; then
    echo "Error: Could not determine the latest release tag from GitHub."
    echo "It's possible GitHub is temporarily blocking requests or your router is offline."
    exit 1
fi

DOWNLOAD_URL="https://github.com/jamesgpt143-arch/my-zapret/releases/download/${TAG}/zapret_${TAG}_${ARCH}.zip"

echo "Downloading package..."
cd /tmp
rm -rf zapret_temp
mkdir -p zapret_temp

curl -sfL "$DOWNLOAD_URL" -o zapret_temp/zapret.zip

if [ $? -ne 0 ]; then
    echo "Error: Could not download the package for architecture $ARCH."
    echo "Attempted URL: $DOWNLOAD_URL"
    echo "Please check https://github.com/jamesgpt143-arch/my-zapret/releases to make sure the build has finished."
    rm -rf zapret_temp
    exit 1
fi

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
echo "FlowVPN Installation Complete!"
echo "You can now go to OpenWrt LuCI Web UI to configure it."
echo "==========================================="
