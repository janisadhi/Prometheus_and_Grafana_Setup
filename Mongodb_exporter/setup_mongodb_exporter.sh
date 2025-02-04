#!/bin/bash

# Update system and install necessary packages
echo "Updating system and installing required packages..."
sudo apt-get update -y
sudo apt-get install -y wget tar mongodb-server

# Download and install the MongoDB Prometheus Exporter
echo "Downloading MongoDB Prometheus Exporter..."
LATEST_RELEASE="0.21.0"  # Replace with the latest version if needed
wget "https://github.com/percona/mongodb_exporter/releases/download/v$LATEST_RELEASE/mongodb_exporter-$LATEST_RELEASE.linux-amd64.tar.gz"

echo "Extracting MongoDB Prometheus Exporter..."
tar -xzvf "mongodb_exporter-$LATEST_RELEASE.linux-amd64.tar.gz"

# Move the binary to /usr/local/bin
sudo mv mongodb_exporter /usr/local/bin/
rm "mongodb_exporter-$LATEST_RELEASE.linux-amd64.tar.gz"

# Create MongoDB Exporter User
echo "Creating mongodb_exporter user..."
sudo useradd -rs /bin/false mongodb_exporter

# Set up MongoDB Exporter authentication
echo "Setting up MongoDB Exporter authentication..."

# MongoDB requires authentication to fetch metrics. Update this with your MongoDB admin credentials.
MONGO_USER="admin"  # MongoDB user with sufficient privileges (change as needed)
MONGO_PASSWORD="admin_password"  # MongoDB user's password
MONGO_DB="admin"  # Database to connect to

# Create systemd service for MongoDB Prometheus Exporter
echo "Creating systemd service for MongoDB Prometheus Exporter..."

echo "[Unit]
Description=MongoDB Prometheus Exporter
After=network.target

[Service]
User=mongodb_exporter
Group=mongodb_exporter
ExecStart=/usr/local/bin/mongodb_exporter --mongodb.uri=mongodb://$MONGO_USER:$MONGO_PASSWORD@localhost:27017/$MONGO_DB

[Install]
WantedBy=multi-user.target
" | sudo tee /etc/systemd/system/mongodb_exporter.service

# Reload systemd, enable and start the service
echo "Enabling and starting MongoDB Prometheus Exporter service..."
sudo systemctl daemon-reload
sudo systemctl enable mongodb_exporter
sudo systemctl start mongodb_exporter

# Verify the service status
echo "Checking MongoDB Prometheus Exporter service status..."
sudo systemctl status mongodb_exporter

# Print final message
echo "MongoDB Prometheus Exporter installation and configuration complete!"
echo "Visit http://<mongodb_exporter_server_ip>:9216/metrics to see the metrics."
echo "You can now add this exporter to your Prometheus configuration and restart Prometheus."
