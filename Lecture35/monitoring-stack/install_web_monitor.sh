#!/bin/bash

echo "--- Починаємо налаштування веб-сервера для моніторингу ---"

# --- 1. Оновлення системи та встановлення базових утиліт ---
echo "1. Оновлення системи та встановлення базових утиліт..."
apt update
apt upgrade -y
apt install -y nginx apache2-utils unzip

# --- 2. Встановлення Node Exporter ---
echo "2. Встановлення Node Exporter..."
wget "https://github.com/prometheus/node_exporter/releases/download/v1.8.1/node_exporter-1.8.1.linux-amd64.tar.gz" -O /tmp/node_exporter.tar.gz
mkdir -p /opt/node_exporter
tar -xvf /tmp/node_exporter.tar.gz -C /opt/node_exporter --strip-components=1
useradd -rs /bin/false node_exporter 2>/dev/null
chown -R node_exporter:node_exporter /opt/node_exporter
chmod +x /opt/node_exporter/node_exporter

tee /etc/systemd/system/node-exporter.service > /dev/null <<EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/opt/node_exporter/node_exporter

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable node-exporter
systemctl start node-exporter
echo "Статус Node Exporter:"
systemctl status node-exporter --no-pager || true

# --- 3. Встановлення Nginx Exporter ---
echo "3. Встановлення Nginx Exporter..."
wget "https://github.com/nginx/nginx-prometheus-exporter/releases/download/v1.2.0/nginx-prometheus-exporter_1.2.0_linux_amd64.tar.gz" -O /tmp/nginx_exporter.tar.gz
mkdir -p /tmp/nginx_exporter_extract
tar -xvf /tmp/nginx_exporter.tar.gz -C /tmp/nginx_exporter_extract/

mkdir -p /opt/nginx_exporter
mv /tmp/nginx_exporter_extract/nginx-prometheus-exporter /opt/nginx_exporter/nginx-prometheus-exporter

rm -rf /tmp/nginx_exporter_extract /tmp/nginx_exporter.tar.gz

chmod +x /opt/nginx_exporter/nginx-prometheus-exporter
useradd -rs /bin/false nginx_exporter 2>/dev/null
chown -R nginx_exporter:nginx_exporter /opt/nginx_exporter

tee /etc/systemd/system/nginx-exporter.service > /dev/null <<EOF
[Unit]
Description=Nginx Prometheus Exporter
Wants=network-online.target
After=network-online.target nginx.service

[Service]
User=nginx_exporter
Group=nginx_exporter
Type=simple
ExecStart=/opt/nginx_exporter/nginx-prometheus-exporter -nginx.scrape-uri http://localhost/nginx_status

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable nginx-exporter
systemctl start nginx-exporter
echo "Статус Nginx Exporter:"
systemctl status nginx-exporter --no-pager || true

# --- 4. Налаштування Nginx ---
echo "4. Налаштування Nginx..."
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak_orig 2>/dev/null # Переміщуємо існуючий конфіг

tee /etc/nginx/nginx.conf > /dev/null <<EOF
events {}

http {
  access_log /var/log/nginx/access.log;
  error_log /var/log/nginx/error.log;

  server {
    listen 80;

    location / {
      return 200 'Nginx is running! Welcome to monitoring homework.';
    }

    location /error {
      return 500 'This is a test server error!';
    }

    location /nginx_status {
      stub_status;
      allow all;
    }
  }
}
EOF
nginx -t
systemctl restart nginx
echo "Статус Nginx:"
systemctl status nginx --no-pager || true

# --- 5. Встановлення Promtail ---
echo "5. Встановлення Promtail..."
wget "https://github.com/grafana/loki/releases/download/v3.0.0/promtail-linux-amd64.zip" -O /tmp/promtail.zip
mkdir -p /tmp/promtail_extract
unzip /tmp/promtail.zip -d /tmp/promtail_extract

mkdir -p /opt/promtail
mv /tmp/promtail_extract/promtail-linux-amd64 /opt/promtail/promtail

rm -rf /tmp/promtail_extract /tmp/promtail.zip

useradd -rs /bin/false promtail 2>/dev/null
chown -R promtail:promtail /opt/promtail
chmod +x /opt/promtail/promtail
mkdir -p /var/lib/promtail
chown promtail:promtail /var/lib/promtail

# ДОДАНО: Додаємо користувача promtail до групи adm для доступу до логів Nginx
echo "Додаємо користувача promtail до групи adm для доступу до логів Nginx..."
usermod -aG adm promtail
echo "Користувач promtail доданий до групи adm."


MONITORING_SERVER_PRIVATE_IP="172.31.9.147" # <--- MONITORING SERVER PRIVATE IP
mkdir -p /etc/promtail
tee /etc/promtail/config.yml > /dev/null <<EOF
server:
  http_listen_port: 9080
  grpc_listen_port: 0
positions:
  filename: /var/lib/promtail/positions.yaml
clients:
  - url: http://${MONITORING_SERVER_PRIVATE_IP}:3100/loki/api/v1/push
scrape_configs:
  - job_name: nginx
    static_configs:
      - targets:
          - localhost
        labels:
          job: nginx
          __path__: /var/log/nginx/*.log
EOF

tee /etc/systemd/system/promtail.service > /dev/null <<EOF
[Unit]
Description=Promtail
Wants=network-online.target
After=network-online.target

[Service]
User=promtail
Group=promtail
Type=simple
ExecStart=/opt/promtail/promtail -config.file=/etc/promtail/config.yml

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable promtail
# ДОДАНО: Перезапускаємо Promtail тут, щоб зміни групи вступили в силу
systemctl restart promtail
echo "Статус Promtail:"
systemctl status promtail --no-pager || true

echo "--- Налаштування веб-сервера завершено! ---"
