#!/bin/bash

echo "CenSecure Dashboard Setup Script"

echo "[*] Updating system..."
sudo apt update && sudo apt install -y python3-pip

echo "[*] Installing Flask..."
pip3 install flask

echo "[*] Creating project structure..."
mkdir -p ~/censecure/dashboard/templates ~/censecure/dashboard/static

echo "[*] Writing Flask app..."
cat << 'EOF' > ~/censecure/dashboard/app.py
from flask import Flask, render_template
import os
import datetime

app = Flask(__name__)

@app.route("/")
def index():
    port_log = read_log("/var/log/censecure_ports.log")
    net_log = read_log("/var/log/censecure_network.log", lines=20)
    auth_log = read_log("/var/log/auth.log", pattern="Failed password")
    return render_template("index.html", 
                           port_log=port_log, 
                           net_log=net_log, 
                           auth_log=auth_log,
                           time=datetime.datetime.now())

def read_log(file_path, lines=10, pattern=None):
    if not os.path.exists(file_path):
        return ["Log file not found."]
    with open(file_path, 'r', errors='ignore') as file:
        lines_list = file.readlines()
        if pattern:
            lines_list = [line for line in lines_list if pattern in line]
        return lines_list[-lines:]

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
EOF

echo "[*] Writing HTML template..."
cat << 'EOF' > ~/censecure/dashboard/templates/index.html
<!DOCTYPE html>
<html>
<head>
    <title>CenSecure Dashboard</title>
    <link rel="stylesheet" href="/static/style.css">
</head>
<body>
    <h1>CenSecure Dashboard</h1>
    <p><strong>Last Updated:</strong> {{ time }}</p>

    <h2>🔒 SSH Intrusion Attempts</h2>
    <pre>{{ auth_log | join('\n') }}</pre>

    <h2>🌐 Open Ports (localhost)</h2>
    <pre>{{ port_log | join('\n') }}</pre>

    <h2>📶 Recent Network Traffic</h2>
    <pre>{{ net_log | join('\n') }}</pre>
</body>
</html>
EOF

echo "[*] Writing CSS..."
cat << 'EOF' > ~/censecure/dashboard/static/style.css
body {
    font-family: monospace;
    background-color: #111;
    color: #0f0;
    padding: 20px;
}
h1, h2 {
    color: #6ff;
}
pre {
    background-color: #222;
    padding: 10px;
    border: 1px solid #333;
    overflow-x: auto;
}
EOF

echo "[*] CenSecure Dashboard setup complete."
echo "🔥 Run the dashboard with:"
echo "   python3 ~/censecure/dashboard/app.py"
echo "💻 Then visit: http://<your-pi-ip>:8080"


