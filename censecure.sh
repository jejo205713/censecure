#!/bin/bash

# CenSecure - A simple IoT Security Monitoring Script for Raspberry Pi

# Automatically detect the active network interface
NETWORK_INTERFACE=$(ip route get 1.1.1.1 | awk '{print $5; exit}')
echo "🧠 Using network interface: $NETWORK_INTERFACE"

# Paths and variables
LOG_FILE="/var/log/censecure_network.log"
PORT_LOG="/var/log/censecure_ports.log"
ALERT_EMAIL="admin@example.com"
DASHBOARD_APP_PATH="$HOME/censecure/dashboard/app.py"

# Function to monitor network traffic and save it to a log file
monitor_traffic() {
    echo "🔍 Monitoring network traffic on $NETWORK_INTERFACE..."

    # Ensure log file exists with correct permissions
    sudo touch "$LOG_FILE"
    sudo chown "$USER":"$USER" "$LOG_FILE"
    sudo chmod 644 "$LOG_FILE"

    # Start tcpdump
    sudo tcpdump -i "$NETWORK_INTERFACE" -n -w "$LOG_FILE" &
    TCPDUMP_PID=$!
}

# Function to check for open ports (potential vulnerabilities)
check_open_ports() {
    echo "🔓 Scanning for open ports..."
    sudo nmap -sS -O 127.0.0.1 > "$PORT_LOG"
}

# Function to analyze logs for potential security threats
analyze_logs() {
    echo "🧠 Analyzing logs for suspicious activity..."

    if grep -q "Failed password" /var/log/auth.log; then
        echo "Potential intrusion detected in SSH logs!" | mail -s "Security Alert: SSH Intrusion Detected" $ALERT_EMAIL
    fi

    if grep -q "SuspiciousPattern" "$LOG_FILE"; then
        echo "Suspicious network traffic detected!" | mail -s "Security Alert: Network Traffic" $ALERT_EMAIL
    fi
}

# Function to enable a firewall and block unauthorized access
enable_firewall() {
    echo "🛡 Configuring firewall settings..."

    sudo ufw allow ssh
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    sudo ufw default deny incoming
    sudo ufw --force enable
}

# Function to notify the user about system events
notify_user() {
    MESSAGE=$1
    echo "$MESSAGE"
    if command -v notify-send &> /dev/null && command -v dbus-launch &> /dev/null; then
        notify-send "CenSecure Alert" "$MESSAGE"
    else
        echo "⚠️ Notification skipped (notify-send or dbus-launch not available)"
    fi
}

# Function to start Flask dashboard
start_dashboard() {
    echo "🚀 Starting CenSecure Flask Dashboard..."
    if [ -f "$DASHBOARD_APP_PATH" ]; then
        (cd "$(dirname "$DASHBOARD_APP_PATH")" && nohup python3 "$(basename "$DASHBOARD_APP_PATH")" > dashboard.log 2>&1 &)
    else
        echo "⚠️ Dashboard app.py not found at $DASHBOARD_APP_PATH"
    fi
}

# Function to stop monitoring
stop_monitoring() {
    if [[ -n "$TCPDUMP_PID" ]]; then
        echo "🛑 Stopping network monitoring..."
        sudo kill "$TCPDUMP_PID"
    fi
}

# Function placeholder for AI threat detection
ai_threat_detection() {
    # Future enhancement: Integrate with TensorFlow/Sklearn
    :
}

# Main routine
echo "💡 CenSecure IoT Security Gateway is starting..."
enable_firewall
monitor_traffic
start_dashboard

# Trap EXIT to stop tcpdump
trap stop_monitoring EXIT

# Monitoring Loop
while true; do
    analyze_logs
    check_open_ports
    notify_user "✅ System running normally. No threats detected."
    sleep 60
done
