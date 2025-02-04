#!/bin/bash

# Set the Node Exporter version (example: v1.5.0)
NODE_EXPORTER_VERSION="1.5.0"

# Download Node Exporter
echo "Downloading Node Exporter version $NODE_EXPORTER_VERSION..."
wget https://github.com/prometheus/node_exporter/releases/download/v$NODE_EXPORTER_VERSION/node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz

# Extract the Node Exporter package
echo "Extracting Node Exporter..."
tar xvfz node_exporter-*.tar.gz

# Move the Node Exporter binary to /usr/local/bin
echo "Moving Node Exporter binary to /usr/local/bin..."
sudo mv node_exporter-$NODE_EXPORTER_VERSION.linux-amd64/node_exporter /usr/local/bin/

# Clean up extracted files
echo "Cleaning up extracted files..."
rm -r node_exporter-$NODE_EXPORTER_VERSION.linux-amd64*

# Create the node_exporter user
echo "Creating node_exporter user..."
sudo useradd -rs /bin/false node_exporter

# Create the Node Exporter systemd service file
echo "Creating systemd service for Node Exporter..."
cat <<EOL | sudo tee /etc/systemd/system/node_exporter.service > /dev/null
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd to recognize the new service
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

# Enable and start Node Exporter as a service
echo "Enabling and starting Node Exporter service..."
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

# Check Node Exporter status
echo "Checking Node Exporter service status..."
sudo systemctl status node_exporter

# Prompt the user to add the client node to Prometheus scrape configuration
echo "Node Exporter is installed and running on this client. Now, you need to update your Prometheus configuration."

echo "Please add the following job in your prometheus.yml file on the monitoring server:"
echo "
- job_name: 'remote_collector'
  scrape_interval: 10s
  static_configs:
    - targets: ['<client_ip>:9100']
"

# Prompt user to restart Prometheus service on the monitoring server
echo "To apply the changes, run the following command on your Prometheus server:"
echo "sudo systemctl restart prometheus"
