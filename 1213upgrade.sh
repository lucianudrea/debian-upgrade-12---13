#!/bin/bash

# Script pentru upgrade de la Debian 12 (Bookworm) la Debian 13 (Trixie)
# Rulează acest script în interiorul containerului LXC

set -e  # Oprește scriptul la prima eroare

echo "=========================================="
echo "Debian 12 -> 13 Upgrade Script"
echo "=========================================="
echo ""

# Verifică dacă scriptul rulează ca root
if [ "$EUID" -ne 0 ]; then 
    echo "ERROR: Acest script trebuie rulat ca root (sudo)"
    exit 1
fi

# Verifică versiunea curentă
echo "Versiune curentă:"
cat /etc/os-release | grep VERSION=
echo ""

# Confirmă upgrade-ul
read -p "Vrei să continui cu upgrade-ul? (da/nu): " confirm
if [ "$confirm" != "da" ]; then
    echo "Upgrade anulat."
    exit 0
fi

echo ""
echo "Pasul 1: Update package list..."
apt update

echo ""
echo "Pasul 2: Backup sources.list..."
cp /etc/apt/sources.list /etc/apt/sources.list.backup
echo "Backup creat: /etc/apt/sources.list.backup"

echo ""
echo "Pasul 3: Schimbă repository-urile la Trixie..."
sed -i 's/bookworm/trixie/g' /etc/apt/sources.list

echo ""
echo "Noua configurație sources.list:"
cat /etc/apt/sources.list
echo ""

read -p "Arată bine? Continui? (da/nu): " confirm2
if [ "$confirm2" != "da" ]; then
    echo "Restaurez backup-ul..."
    mv /etc/apt/sources.list.backup /etc/apt/sources.list
    echo "Upgrade anulat."
    exit 0
fi

echo ""
echo "Pasul 4: Update cu noile repository-uri..."
apt update

echo ""
echo "Pasul 5: Efectuare full-upgrade (poate dura ceva timp)..."
DEBIAN_FRONTEND=noninteractive apt full-upgrade -y

echo ""
echo "Pasul 6: Curățare pachete obsolete..."
apt autoremove -y
apt autoclean

echo ""
echo "=========================================="
echo "Upgrade finalizat!"
echo "=========================================="
echo ""
echo "Versiune nouă:"
cat /etc/os-release | grep VERSION=
echo ""
echo "Se recomandă restart-ul containerului."
read -p "Vrei să restart-ezi acum? (da/nu): " restart
if [ "$restart" == "da" ]; then
    echo "Restart în curs..."
    reboot
fi