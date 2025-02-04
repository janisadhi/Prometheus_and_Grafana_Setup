# Prometheus and Grafana Setup

This repository provides scripts to set up monitoring and visualization using **Prometheus** and **Grafana**. The setup includes exporting metrics from various services like MySQL, MongoDB, NGINX, and Node.js to Prometheus, and visualizing them on Grafana.

## Prerequisites

Before running the scripts, ensure that your system meets the following requirements:
- Ubuntu/Debian-based Linux distribution
- Root or sudo privileges for package installations
- Internet access to download necessary packages and dependencies

## Setup Instructions

### 1. Clone the Repository
First, clone this repository to your local machine or server:

```bash
git clone https://github.com/janisadhi/Prometheus_and_Grafana_Setup.git
cd Prometheus_and_Grafana_Setup
```

### 2. Prometheus Setup
Prometheus is a powerful monitoring system that collects and stores metrics as time series data. To install Prometheus, follow these steps:

- Navigate to the `Prometheus` directory:
  ```bash
  cd Prometheus
  ```

- **Make the script executable:**
  ```bash
  chmod +x setupt_prometheus.sh
  ```

- Run the setup script:
  ```bash
  sudo ./setupt_prometheus.sh
  ```

- Access Prometheus at `http://<your_server_ip>:9090`.

### 3. Grafana Setup
Grafana is a visualization tool used to create dashboards based on the data collected by Prometheus. To install Grafana, follow these steps:

- Navigate to the `Grafana` directory:
  ```bash
  cd Grafana
  ```

- **Make the script executable:**
  ```bash
  chmod +x setup_grafana.sh
  ```

- Run the setup script:
  ```bash
  sudo ./setup_grafana.sh
  ```

- Access Grafana at `http://<your_server_ip>:3000`. The default username is `admin` with the password `admin`.

### 4. Exporters Setup
Various exporters are provided to collect metrics from different services. Run the following scripts to install the exporters:

#### 4.1 Node Exporter
Node Exporter collects hardware and OS metrics from the host machine.

- Navigate to the `Node_exporter` directory:
  ```bash
  cd Node_exporter
  ```

- **Make the script executable:**
  ```bash
  chmod +x setup_node_exporter.sh
  ```

- Run the setup script:
  ```bash
  sudo ./setup_node_exporter.sh
  ```

#### 4.2 MySQL Exporter
MySQL Exporter collects MySQL database metrics.

- Navigate to the `Mysql_exporter` directory:
  ```bash
  cd Mysql_exporter
  ```

- **Make the script executable:**
  ```bash
  chmod +x setup_mysql_exporter.sh
  ```

- Run the setup script:
  ```bash
  sudo ./setup_mysql_exporter.sh
  ```

#### 4.3 MongoDB Exporter
MongoDB Exporter collects MongoDB database metrics.

- Navigate to the `Mongodb_exporter` directory:
  ```bash
  cd Mongodb_exporter
  ```

- **Make the script executable:**
  ```bash
  chmod +x setup_mongodb_exporter.sh
  ```

- Run the setup script:
  ```bash
  sudo ./setup_mongodb_exporter.sh
  ```

#### 4.4 NGINX Exporter
NGINX Exporter collects NGINX metrics.

- Navigate to the `Nginix_exporter` directory:
  ```bash
  cd Nginix_exporter
  ```

- **Make the script executable:**
  ```bash
  chmod +x setup_nginix-exporter.sh
  ```

- Run the setup script:
  ```bash
  sudo ./setup_nginix-exporter.sh
  ```

### 5. Update Prometheus Configuration
After setting up the exporters, you need to update your Prometheus configuration to scrape metrics from the services. Follow these steps:

- Open the `prometheus.yml` file for editing:
  ```bash
  sudo nano /etc/prometheus/prometheus.yml
  ```

- Add the following scrape jobs to the `scrape_configs` section for each exporter:

  ```yaml
  scrape_configs:
    - job_name: 'node'
      static_configs:
        - targets: ['<node_exporter_ip>:9100']
  
    - job_name: 'mysql'
      static_configs:
        - targets: ['<mysql_exporter_ip>:9104']

    - job_name: 'mongodb'
      static_configs:
        - targets: ['<mongodb_exporter_ip>:9216']

    - job_name: 'nginx'
      static_configs:
        - targets: ['<nginx_exporter_ip>:9113']
  ```

- Replace `<node_exporter_ip>`, `<mysql_exporter_ip>`, `<mongodb_exporter_ip>`, and `<nginx_exporter_ip>` with the actual IP addresses of the respective exporters.

- After updating the configuration, restart the Prometheus service:
  ```bash
  sudo systemctl restart prometheus
  ```

### 6. Add Data Sources in Grafana
Now that Prometheus is scraping data from the exporters, you'll need to integrate Prometheus with Grafana.

- Log in to Grafana at `http://<your_server_ip>:3000` using the default credentials (`admin`/`admin`).
- Navigate to **Configuration** > **Data Sources**.
- Click **Add data source**, and select **Prometheus**.
- In the **URL** field, enter `http://<your_prometheus_ip>:9090`.
- Click **Save & Test** to confirm that Grafana is able to connect to Prometheus.

### 7. Create Dashboards in Grafana
You can now create dashboards in Grafana based on the data collected from Prometheus. You can either create custom dashboards or import pre-built ones from the Grafana dashboard repository.

## Additional Notes
- Make sure your firewall allows traffic on ports `9090` (Prometheus) and `3000` (Grafana).
- Ensure that the services you're monitoring (MySQL, MongoDB, NGINX, Node.js) are running and accessible from the server where Prometheus is running.
- For each exporter, adjust the script settings (e.g., MySQL credentials, MongoDB authentication) according to your environment.

