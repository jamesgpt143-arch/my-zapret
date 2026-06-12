#!/bin/sh

echo "==========================================="
echo " FlowVPN OpenWrt - Uninstaller"
echo "==========================================="

echo "Stopping FlowVPN service..."
/etc/init.d/zapret stop 2>/dev/null
/etc/init.d/zapret disable 2>/dev/null

echo "Removing packages..."
opkg remove luci-app-zapret
opkg remove zapret

echo "Removing leftover configuration files..."
rm -rf /opt/zapret
rm -f /etc/config/zapret

echo "==========================================="
echo "FlowVPN has been completely uninstalled!"
echo "==========================================="
