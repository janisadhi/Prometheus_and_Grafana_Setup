#!/bin/bash

# Update and install necessary packages
echo "Updating system and installing required packages..."
sudo apt-get update -y
sudo apt-get install -y wget tar nginx

# Download and install the NGINX Prometheus Exporter
echo "Downloading NGINX Prometheus Exporter..."
LATEST_RELEASE="0.10.0"  # Replace with the latest version if needed
wget "https://github.com/nginxinc/nginx-prometheus-exporter/releases/download/v$LATEST_RELEASE/nginx-prometheus-exporter-$LATEST_RELEASE.amd64.tar.gz"

echo "Extracting NGINX Prometheus Exporter..."
tar -xzvf "nginx-prometheus-exporter-$LATEST_RELEASE.amd64.tar.gz"

# Move the binary to /usr/local/bin
sudo mv nginx-prometheus-exporter /usr/local/bin/
rm "nginx-prometheus-exporter-$LATEST_RELEASE.amd64.tar.gz"

# Configure NGINX for the status page
echo "Configuring NGINX for the status page..."

# Backup the original nginx.conf before modifying
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak

# Add status location to NGINX config
echo "
server {
    listen 127.0.0.1:8080;
    server_name localhost;

    location /status {
        stub_status on;
        access_log off;
        allow 127.0.0.1;
        deny all;
    }
}
" | sudo tee -a /etc/nginx/nginx.conf

# Reload NGINX to apply the changes
echo "Reloading NGINX..."
sudo systemctl reload nginx

# Create systemd service for NGINX Prometheus Exporter
echo "Creating systemd service for NGINX Prometheus Exporter..."

echo "[Unit]
Description=NGINX Prometheus Exporter
After=network.target

[Service]
User=nobody
ExecStart=/usr/local/bin/nginx-prometheus-exporter -nginx.scrape-uri=http://127.0.0.1:8080/status
Restart=always

[Install]
WantedBy=multi-user.target
" | sudo tee /etc/systemd/system/nginx-prometheus-exporter.service

# Reload systemd, enable and start the service
echo "Enabling and starting NGINX Prometheus Exporter service..."
sudo systemctl daemon-reload
sudo systemctl enable nginx-prometheus-exporter
sudo systemctl start nginx-prometheus-exporter

# Verify the service status
echo "Checking NGINX Prometheus Exporter service status..."
sudo systemctl status nginx-prometheus-exporter

# Print final message
echo "NGINX Prometheus Exporter installation and configuration complete!"
echo "Visit http://<nginx_server_ip>:9113/metrics to see the metrics."
echo "You can now add this exporter to your Prometheus configuration and restart Prometheus."
