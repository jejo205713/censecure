#!/bin/bash

# CenSecure - A simple IoT Security Monitoring Script for Raspberry Pi or Linux

# Auto-detect default network interface
NETWORK_INTERFACE=$(ip route | awk '/default/ { print $5; exit }')
echo "🧠 Using network interface: $NETWORK_INTERFACE"

# Directory and log paths
LOG_DIR="$HOME/censecure_logs"
LOG_FILE="$LOG_DIR/network.log"
PORT_LOG_FILE="$LOG_DIR/ports.log"
ALERT_EMAIL="admin@example.com"
DASHBOARD_PATH="$HOME/censecure/dashboard"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Function to monitor network traffic and save to a log file
monitor_traffic() {
    echo "🔍 Monitoring network traffic on $NETWORK_INTERFACE..."
    sudo touch "$LOG_FILE"
    sudo chown $(whoami):$(whoami) "$LOG_FILE"
    sudo tcpdump -i "$NETWORK_INTERFACE" -n -w "$LOG_FILE" &
    TCPDUMP_PID=$!
}

# Function to scan for open ports
check_open_ports() {
    echo "🔓 Scanning for open ports..."
    sudo nmap -sS -O 127.0.0.1 > "$PORT_LOG_FILE"
}

# Function to analyze logs for threats
analyze_logs() {
    echo "🧠 Analyzing logs for suspicious activity..."

    if grep -q "Failed password" /var/log/auth.log; then
        echo "🚨 Potential SSH intrusion detected!" | mail -s "CenSecure Alert: SSH Intrusion" "$ALERT_EMAIL"
    fi

    if grep -q "SuspiciousPattern" "$LOG_FILE" 2>/dev/null; then
        echo "🚨 Suspicious network traffic detected!" | mail -s "CenSecure Alert: Network Traffic" "$ALERT_EMAIL"
    fi
}

# Configure UFW firewall
enable_firewall() {
    echo "🛡 Configuring firewall settings..."
    sudo ufw allow ssh
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    sudo ufw default deny incoming
    sudo ufw --force enable
}

# Notify user of system status
notify_user() {
    MESSAGE=$1
    echo "✅ $MESSAGE"
    
    if command -v notify-send &> /dev/null && command -v dbus-launch &> /dev/null; then
        notify-send "CenSecure Alert" "$MESSAGE"
    else
        echo "⚠️ Notification skipped (notify-send or dbus-launch not available)"
    fi
}

# Stop network monitoring
stop_monitoring() {
    if [[ -n "$TCPDUMP_PID" ]]; then
        echo "🛑 Stopping network monitoring..."
        sudo kill "$TCPDUMP_PID"
    fi
}

# Launch termui dashboard
start_dashboard() {
    echo "🚀 Starting CenSecure Dashboard with termui..."

    # Create a Python script for the dashboard
    DASHBOARD_SCRIPT="$DASHBOARD_PATH/dashboard.py"
    
    cat > "$DASHBOARD_SCRIPT" <<EOL
import time
import termui
from termui import ui

# Create a basic terminal interface
def create_dashboard():
    window = ui.Window(title="CenSecure IoT Security Gateway", width=50, height=15)

    # Add some sample data (you can replace these with dynamic logs or variables)
    network_traffic = "Monitoring network traffic..."
    port_status = "Ports scanned: 22, 80, 443"
    firewall_status = "Firewall is active"
    alert_status = "No threats detected"

    # Add the text to the UI
    window.add(ui.Text(network_traffic, x=1, y=1))
    window.add(ui.Text(port_status, x=1, y=3))
    window.add(ui.Text(firewall_status, x=1, y=5))
    window.add(ui.Text(alert_status, x=1, y=7))

    # Start the UI loop
    window.run()

# Run the dashboard
create_dashboard()
EOL

    # Run the dashboard script using Python
    if command -v python3 &> /dev/null; then
        python3 "$DASHBOARD_SCRIPT" &
    else
        echo "⚠️ Python3 is not installed. Unable to run the dashboard."
    fi
}

# Placeholder for AI model integration
ai_threat_detection() {
    # Future AI threat detection integration
    :
}

# Trap to clean up on exit
trap stop_monitoring EXIT

# Start of main script
echo "💡 CenSecure IoT Security Gateway is starting..."
enable_firewall
monitor_traffic
start_dashboard

# Monitoring loop
while true; do
    analyze_logs
    check_open_ports
    notify_user "System running normally. No threats detected."
    sleep 60
done
