#!/bin/bash

# Set Prometheus version
PROMETHEUS_VERSION="2.37.6"

# Download Prometheus
echo "Downloading Prometheus version $PROMETHEUS_VERSION..."
wget https://github.com/prometheus/prometheus/releases/download/v$PROMETHEUS_VERSION/prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz

# Extract Prometheus
echo "Extracting Prometheus..."
tar xvfz prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz

# Clean up archive
echo "Cleaning up downloaded archive..."
rm prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz

# Create necessary directories
echo "Creating directories for Prometheus..."
sudo mkdir -p /etc/prometheus /var/lib/prometheus

# Move Prometheus files
echo "Moving Prometheus files to appropriate directories..."
cd prometheus-$PROMETHEUS_VERSION.linux-amd64
sudo mv prometheus promtool /usr/local/bin/
sudo mv prometheus.yml /etc/prometheus/prometheus.yml
sudo mv consoles/ console_libraries/ /etc/prometheus/

# Verify Prometheus installation
echo "Verifying Prometheus installation..."
prometheus --version

# Create Prometheus user
echo "Creating Prometheus user..."
sudo useradd -rs /bin/false prometheus

# Set ownership of Prometheus directories
echo "Setting ownership of Prometheus directories..."
sudo chown -R prometheus: /etc/prometheus /var/lib/prometheus

# Create systemd service file for Prometheus
echo "Creating Prometheus service file..."
cat <<EOL | sudo tee /etc/systemd/system/prometheus.service > /dev/null
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries \
    --web.listen-address=0.0.0.0:9090 \
    --web.enable-lifecycle \
    --log.level=info

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd daemon
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

# Enable Prometheus service to start on boot
echo "Enabling Prometheus service to start on boot..."
sudo systemctl enable prometheus

# Start Prometheus service
echo "Starting Prometheus service..."
sudo systemctl start prometheus

# Check Prometheus service status
echo "Checking Prometheus service status..."
sudo systemctl status prometheus

# Success message
echo "Prometheus installation and setup completed successfully. You can access the Prometheus web UI at http://<your_server_ip>:9090."
