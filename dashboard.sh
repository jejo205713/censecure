#!/bin/bash

# Install termui for creating terminal-based dashboards

echo "💡 Installing termui for terminal-based UI..."

# Update package lists and upgrade existing packages
sudo apt update -y && sudo apt upgrade -y

# Install Python and pip (if not installed)
echo "🔧 Checking for Python and pip..."
if ! command -v python3 &> /dev/null
then
    echo "Python not found. Installing Python 3..."
    sudo apt install python3 -y
fi

if ! command -v pip3 &> /dev/null
then
    echo "pip not found. Installing pip..."
    sudo apt install python3-pip -y
fi

# Install termui Python library
echo "📦 Installing termui..."
pip3 install termui

# Confirm installation
if python3 -c "import termui" &> /dev/null; then
    echo "✅ termui successfully installed!"
else
    echo "⚠️ Failed to install termui."
fi
