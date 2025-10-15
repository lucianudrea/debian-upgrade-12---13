#!/bin/bash

# Script to upgrade from Debian 12 (Bookworm) to Debian 13 (Trixie)
# Run this script inside the LXC container

set -e  # Stop script on first error

echo "=========================================="
echo "Debian 12 -> 13 Upgrade Script"
echo "=========================================="
echo ""

# Check if script is running as root
if [ "$EUID" -ne 0 ]; then 
    echo "ERROR: This script must be run as root (sudo)"
    exit 1
fi

# Check current version
echo "Current version:"
cat /etc/os-release | grep VERSION=
echo ""

# Confirm upgrade
read -p "Do you want to continue with the upgrade? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Upgrade cancelled."
    exit 0
fi

echo ""
echo "Step 1: Update package list..."
apt update

echo ""
echo "Step 2: Backup sources.list..."
cp /etc/apt/sources.list /etc/apt/sources.list.backup
echo "Backup created: /etc/apt/sources.list.backup"

echo ""
echo "Step 3: Change repositories to Trixie..."
sed -i 's/bookworm/trixie/g' /etc/apt/sources.list

echo ""
echo "New sources.list configuration:"
cat /etc/apt/sources.list
echo ""

read -p "Looks good? Continue? (yes/no): " confirm2
if [ "$confirm2" != "yes" ]; then
    echo "Restoring backup..."
    mv /etc/apt/sources.list.backup /etc/apt/sources.list
    echo "Upgrade cancelled."
    exit 0
fi

echo ""
echo "Step 4: Update with new repositories..."
apt update

echo ""
echo "Step 5: Performing full-upgrade (this may take a while)..."
DEBIAN_FRONTEND=noninteractive apt full-upgrade -y

echo ""
echo "Step 6: Cleaning up obsolete packages..."
apt autoremove -y
apt autoclean

echo ""
echo "=========================================="
echo "Upgrade completed!"
echo "=========================================="
echo ""
echo "New version:"
cat /etc/os-release | grep VERSION=
echo ""
echo "Container restart is recommended."
read -p "Do you want to restart now? (yes/no): " restart
if [ "$restart" == "yes" ]; then
    echo "Restarting..."
    reboot
fi