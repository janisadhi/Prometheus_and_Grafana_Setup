#!/bin/bash

# Set variables for Grafana installation
GRAFANA_GPG_URL="https://apt.grafana.com/gpg.key"
GRAFANA_REPO="deb [signed-by=/usr/share/keyrings/grafana.key] https://apt.grafana.com stable main"
GRAFANA_VERSION="grafana"

# Update and install required packages
echo "Updating package list and installing required utilities..."
sudo apt-get update && sudo apt-get install -y apt-transport-https software-properties-common wget curl

# Import the Grafana GPG key
echo "Importing the Grafana GPG key..."
sudo wget -q -O /usr/share/keyrings/grafana.key "$GRAFANA_GPG_URL"

# Add the Grafana repository
echo "Adding the Grafana repository..."
echo "$GRAFANA_REPO" | sudo tee -a /etc/apt/sources.list.d/grafana.list

# Update the package list to include the Grafana repository
echo "Updating package list again..."
sudo apt-get update

# Install Grafana
echo "Installing Grafana..."
sudo apt-get install -y "$GRAFANA_VERSION"

# Reload systemd daemon to recognize the new Grafana service
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

# Enable and start the Grafana service
echo "Enabling and starting Grafana server..."
sudo systemctl enable grafana-server.service
sudo systemctl start grafana-server

# Check the status of the Grafana service
echo "Checking Grafana service status..."
sudo systemctl status grafana-server

# Instructions to set up Grafana
echo "Grafana has been installed and started successfully."
echo "Access Grafana dashboard via http://<your_server_ip>:3000"
echo "Default login: admin/admin. Make sure to change the password after logging in."
echo "You can now add Prometheus as a data source in the Grafana web interface."

# End of script
