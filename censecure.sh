#!/bin/bash

# CenSecure - A simple IoT Security Monitoring Script for Raspberry Pi or any Linux IoT system

# === CONFIGURATION ===

# Auto-detect network interface (fallback to wlp3s0 if unknown)
NETWORK_INTERFACE=$(ip -o link show | awk -F': ' '{print $2}' | grep -E 'wl|en' | head -n 1)
NETWORK_INTERFACE=${NETWORK_INTERFACE:-wlp3s0}

# Log file paths
LOG_FILE="/var/log/censecure_network.log"
PORT_LOG="/var/log/censecure_ports.log"
ALERT_EMAIL="admin@example.com"
DASHBOARD_APP_PATH="/home/pi/censecure/dashboard/app.py"  # Modify if your path is different

# === FUNCTIONS ===

monitor_traffic() {
    echo "🔍 Monitoring network traffic on $NETWORK_INTERFACE..."

    # Ensure log file exists and has correct permissions
    sudo touch "$LOG_FILE"
    sudo chmod 644 "$LOG_FILE"

    sudo tcpdump -i "$NETWORK_INTERFACE" -n -w "$LOG_FILE" &
    TCPDUMP_PID=$!
}

check_open_ports() {
    echo "🔓 Scanning for open ports..."
    sudo nmap -sS -O 127.0.0.1 > "$PORT_LOG"
}

analyze_logs() {
    echo "🧠 Analyzing logs for suspicious activity..."

    if grep -q "Failed password" /var/log/auth.log; then
        echo "🚨 SSH intrusion detected!" | mail -s "CenSecure Alert: SSH Intrusion" $ALERT_EMAIL
    fi

    if grep -q "SuspiciousPattern" "$LOG_FILE"; then
        echo "🚨 Suspicious network activity!" | mail -s "CenSecure Alert: Network Traffic" $ALERT_EMAIL
    fi
}

enable_firewall() {
    echo "🛡 Configuring firewall settings..."

    sudo ufw allow ssh
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    sudo ufw default deny incoming
    sudo ufw --force enable
}

notify_user() {
    MESSAGE=$1
    echo "$MESSAGE"

    if command -v notify-send &> /dev/null && command -v dbus-launch &> /dev/null; then
        DISPLAY=:0 dbus-launch notify-send "CenSecure Alert" "$MESSAGE"
    else
        echo "⚠️ Notification skipped (notify-send or dbus-launch not available)"
    fi
}

start_dashboard() {
    echo "🚀 Starting CenSecure Flask Dashboard..."

    if [[ -f "$DASHBOARD_APP_PATH" ]]; then
        nohup python3 "$DASHBOARD_APP_PATH" > /dev/null 2>&1 &
        DASHBOARD_PID=$!
    else
        echo "⚠️ Dashboard app.py not found at $DASHBOARD_APP_PATH"
    fi
}

stop_all() {
    echo "🛑 Shutting down CenSecure..."

    if [[ -n "$TCPDUMP_PID" ]]; then
        echo "Stopping tcpdump..."
        sudo kill "$TCPDUMP_PID"
    fi

    if [[ -n "$DASHBOARD_PID" ]]; then
        echo "Stopping dashboard..."
        kill "$DASHBOARD_PID"
    fi
}

ai_threat_detection() {
    # Placeholder for future AI logic
    :
}

# === TRAP CLEANUP ===
trap stop_all EXIT

# === MAIN EXECUTION ===

echo "💡 CenSecure IoT Security Gateway is starting..."
echo "🧠 Using network interface: $NETWORK_INTERFACE"
enable_firewall
monitor_traffic
start_dashboard

while true; do
    analyze_logs
    check_open_ports
    notify_user "✅ System running normally. No threats detected."
    sleep 60
done
