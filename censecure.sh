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
DASHBOARD_PATH="$HOME/censecure/dashboard/app.py"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Function to monitor network traffic and save to a log file
monitor_traffic() {
    echo "🔍 Monitoring network traffic on $NETWORK_INTERFACE..."
    
    # Ensure log file exists with correct permissions
    sudo touch "$LOG_FILE"
    sudo chown $(whoami):$(whoami) "$LOG_FILE"

    # Start tcpdump with proper privileges
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

    # Check for failed SSH logins
    if grep -q "Failed password" /var/log/auth.log; then
        echo "🚨 Potential SSH intrusion detected!" | mail -s "CenSecure Alert: SSH Intrusion" "$ALERT_EMAIL"
    fi

    # Dummy pattern match for suspicious traffic
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

# Launch Flask dashboard
start_dashboard() {
    echo "🚀 Starting CenSecure Flask Dashboard..."
    if [[ -f "$DASHBOARD_PATH" ]]; then
        (cd "$(dirname "$DASHBOARD_PATH")" && python3 app.py &)
    else
        echo "⚠️ Dashboard app.py not found at $DASHBOARD_PATH"
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
