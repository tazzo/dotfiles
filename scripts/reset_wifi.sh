#!/bin/sh

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Questo script deve essere eseguito con sudo. Esegui: sudo ./reset_wifi.sh"
  exit 1
fi

echo "Attempting to reset Wi-Fi..."

echo "1. Disabling Wi-Fi via NetworkManager..."
nmcli radio wifi off

sleep 1

echo "2. Unloading wl kernel module..."
modprobe -r wl 2>/dev/null || echo "wl module not loaded or not found, skipping."

sleep 1

echo "3. Loading wl kernel module..."
modprobe wl 2>/dev/null || echo "wl module not found, skipping."

sleep 1

echo "4. Enabling Wi-Fi via NetworkManager..."
nmcli radio wifi on

echo "Wi-Fi reset attempt complete. Please check your connection."
