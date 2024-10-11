# CenSecure - IoT Security Gateway for Raspberry Pi

## Overview

**CenSecure** is an open-source security monitoring solution designed to enhance the security of IoT devices. Built to run on a Raspberry Pi, this project aims to provide a simple, efficient, and flexible framework for network traffic monitoring, log analysis, and firewall management to protect IoT devices from unauthorized access and network-based threats.

This is the **base code** of the CenSecure project, and we're actively working on integrating additional features such as AI-driven threat detection and advanced real-time alerts. In the future, CenSecure will evolve into a fully integrated **hardware device** for centralized IoT security.

## Features

- **Network Traffic Monitoring**: Uses `tcpdump` to capture and log network traffic.
- **Port Scanning**: Detects open ports on local machines using `nmap`.
- **Log Analysis**: Monitors system logs for suspicious activity (e.g., failed SSH login attempts).
- **Firewall Management**: Configures and manages a firewall using `ufw` to block unauthorized access.
- **Real-Time Alerts**: Sends notifications via email or desktop alerts when potential security threats are detected.

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/CenSecure.git
   ```
2.Installing dependencies & running :
   ```bash
   cd CenSecure && sudo sh install.sh
```
