#!/bin/bash

# Step 1: Update package list
echo "Updating package list..."
sudo apt-get update

# Step 2: Install required packages
echo "Installing required packages..."
sudo apt-get install -y tcpdump nmap ufw mailutils

# Step 3: Make the CenSecure script executable
echo "Making the CenSecure script executable..."
chmod +x CenSecure.sh

# Step 4: Run the CenSecure script with superuser privileges
echo "Running the CenSecure script..."
sudo ./CenSecure.sh
