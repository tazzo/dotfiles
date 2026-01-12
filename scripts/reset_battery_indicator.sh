#!/bin/bash
# Script to reset the system's power management service (upower).

echo "Attempting to restart the UPower service..."
echo "This is a system service and will require sudo privileges."

# Restarting upowerd, which provides power information to the system
sudo systemctl restart upower.service

# Check the exit code of the restart command
if [ $? -eq 0 ]; then
    echo "UPower service restarted successfully."
    echo "The battery indicator should update with the correct status shortly."
else
    echo "Failed to restart UPower service. Please check for errors."
    echo "You might need to run this script with sudo or check system logs for more details."
fi