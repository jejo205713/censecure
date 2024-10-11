#!/bin/bash

# CenSecure - A simple IoT Security Monitoring Script for Raspberry Pi

# Network Interface (You can modify this based on your device's interface)
NETWORK_INTERFACE="wlan0"

# Log file for storing network traffic
LOG_FILE="/var/log/censecure_network.log"
ALERT_EMAIL="admin@example.com"

# Function to monitor network traffic and save it to a log file
monitor_traffic() {
    echo "Monitoring network traffic on $NETWORK_INTERFACE..."
    sudo tcpdump -i $NETWORK_INTERFACE -n -w $LOG_FILE &
    TCPDUMP_PID=$!
}

# Function to check for open ports (potential vulnerabilities)
check_open_ports() {
    echo "Scanning for open ports..."
    sudo nmap -sS -O 127.0.0.1 > /var/log/censecure_ports.log
}

# Function to analyze the logs for potential security threats
analyze_logs() {
    echo "Analyzing logs for suspicious activity..."
    
    # Check for failed SSH login attempts
    if grep -q "Failed password" /var/log/auth.log; then
        echo "Potential intrusion detected in SSH logs!" | mail -s "Security Alert: SSH Intrusion Detected" $ALERT_EMAIL
    fi
    
    # Example: Grep the network log for anomalies (replace with actual logic)
    if grep -q "SuspiciousPattern" $LOG_FILE; then
        echo "Suspicious network traffic detected!" | mail -s "Security Alert: Network Traffic" $ALERT_EMAIL
    fi
}

# Function to enable a firewall and block unauthorized access
enable_firewall() {
    echo "Configuring firewall settings..."
    
    sudo ufw allow ssh
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    sudo ufw default deny incoming
    sudo ufw enable
}

# Function to notify the user about system events (Can be extended with advanced AI/ML models)
notify_user() {
    MESSAGE=$1
    echo "$MESSAGE"
    # Send a desktop notification (if GUI is available)
    if command -v notify-send &> /dev/null; then
        notify-send "CenSecure Alert" "$MESSAGE"
    fi
}

# Function to stop monitoring
stop_monitoring() {
    if [[ -n "$TCPDUMP_PID" ]]; then
        echo "Stopping network monitoring..."
        sudo kill $TCPDUMP_PID
    fi
}

# Function to integrate with AI model (Extendable)
ai_threat_detection() {
    #AI threat detection placeholder - AI tools like TensorFlow or Scikit-learn will be added here "
}

# Main loop
echo "CenSecure IoT Security Gateway is starting..."
enable_firewall
monitor_traffic

# Monitoring Loop (Checks logs every minute)
while true; do
    analyze_logs
    check_open_ports
    notify_user "System running normally. No threats detected."
    sleep 60  # Adjust this interval as needed
done

# Stop monitoring when the script exits
trap stop_monitoring EXIT
