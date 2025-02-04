#!/bin/bash

# Update system and install necessary packages
echo "Updating system and installing required packages..."
sudo apt-get update -y
sudo apt-get install -y wget tar mysql-server libmysqlclient-dev

# Download and install the MySQL Prometheus Exporter
echo "Downloading MySQL Prometheus Exporter..."
LATEST_RELEASE="0.15.0"  # Replace with the latest version if needed
wget "https://github.com/prometheus/mysqld_exporter/releases/download/v$LATEST_RELEASE/mysqld_exporter-$LATEST_RELEASE.linux-amd64.tar.gz"

echo "Extracting MySQL Prometheus Exporter..."
tar -xzvf "mysqld_exporter-$LATEST_RELEASE.linux-amd64.tar.gz"

# Move the binary to /usr/local/bin
sudo mv mysqld_exporter /usr/local/bin/
rm "mysqld_exporter-$LATEST_RELEASE.linux-amd64.tar.gz"

# Create MySQL Exporter User
echo "Creating mysql_exporter user..."
sudo useradd -rs /bin/false mysql_exporter

# Set up MySQL Exporter credentials
echo "Setting up MySQL Exporter credentials..."

# Create MySQL user with the necessary privileges
MYSQL_ROOT_PASSWORD="root_password"  # Change this to your MySQL root password
MYSQL_EXPORTER_PASSWORD="exporter_password"  # Change this to a secure password for the exporter

# Log in to MySQL and create the exporter user
sudo mysql -u root -p$MYSQL_ROOT_PASSWORD -e "CREATE USER 'mysqld_exporter'@'localhost' IDENTIFIED BY '$MYSQL_EXPORTER_PASSWORD';"
sudo mysql -u root -p$MYSQL_ROOT_PASSWORD -e "GRANT PROCESS, REPLICATION CLIENT ON *.* TO 'mysqld_exporter'@'localhost';"
sudo mysql -u root -p$MYSQL_ROOT_PASSWORD -e "FLUSH PRIVILEGES;"

# Create systemd service for MySQL Prometheus Exporter
echo "Creating systemd service for MySQL Prometheus Exporter..."

echo "[Unit]
Description=MySQL Prometheus Exporter
After=network.target

[Service]
User=mysql_exporter
Group=mysql_exporter
ExecStart=/usr/local/bin/mysqld_exporter --mysql.uri=mysqld_exporter:$MYSQL_EXPORTER_PASSWORD@tcp(localhost:3306)/

[Install]
WantedBy=multi-user.target
" | sudo tee /etc/systemd/system/mysqld_exporter.service

# Reload systemd, enable and start the service
echo "Enabling and starting MySQL Prometheus Exporter service..."
sudo systemctl daemon-reload
sudo systemctl enable mysqld_exporter
sudo systemctl start mysqld_exporter

# Verify the service status
echo "Checking MySQL Prometheus Exporter service status..."
sudo systemctl status mysqld_exporter

# Print final message
echo "MySQL Prometheus Exporter installation and configuration complete!"
echo "Visit http://<mysql_exporter_server_ip>:9104/metrics to see the metrics."
echo "You can now add this exporter to your Prometheus configuration and restart Prometheus."
