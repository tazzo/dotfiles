#!/bin/bash

LOG_FILE="/home/taz/.gemini/tmp/wireguard_check_log.txt"

echo "Running WireGuard VPN status check. Output will be saved to $LOG_FILE"
echo "----------------------------------------------------------------------" > "$LOG_FILE"
echo "Date: $(date)" >> "$LOG_FILE"
echo "----------------------------------------------------------------------" >> "$LOG_FILE"

echo "Please activate your 'taz-macbook' WireGuard VPN connection now (e.g., via GUI or 'nmcli connection up taz-macbook')."
echo "Press Enter once the VPN connection is active to continue the script."
read -r

echo "" >> "$LOG_FILE"
echo "### nmcli connection show --active ###" >> "$LOG_FILE"
nmcli connection show --active >> "$LOG_FILE" 2>&1

echo "" >> "$LOG_FILE"
echo "### nmcli connection show taz-macbook (Configuration Details) ###" >> "$LOG_FILE"
nmcli connection show taz-macbook >> "$LOG_FILE" 2>&1

echo "" >> "$LOG_FILE"
echo "### sudo wg show taz-macbook ###" >> "$LOG_FILE"
sudo wg show taz-macbook >> "$LOG_FILE" 2>&1

echo "" >> "$LOG_FILE"
echo "### ip r show dev taz-macbook ###" >> "$LOG_FILE"
ip r show dev taz-macbook >> "$LOG_FILE" 2>&1

echo "" >> "$LOG_FILE"
echo "### resolvectl status ###" >> "$LOG_FILE"
resolvectl status >> "$LOG_FILE" 2>&1

echo "" >> "$LOG_FILE"
echo "### lsmod | grep wireguard (Kernel Module Check) ###" >> "$LOG_FILE"
lsmod | grep wireguard >> "$LOG_FILE" 2>&1

echo "----------------------------------------------------------------------" >> "$LOG_FILE"
echo "WireGuard status check completed. Logs saved to $LOG_FILE"
echo "----------------------------------------------------------------------"

echo ""
echo "Please deactivate your 'taz-macbook' WireGuard VPN connection now (e.g., via GUI or 'nmcli connection down taz-macbook')."
echo "Press Enter once the VPN connection is deactivated."
read -r

echo "Script finished."