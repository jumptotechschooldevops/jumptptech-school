---
title: "how to install prometheus"
description: "1. Connect to Ubuntu EC2      ssh -i your-key.pem ubuntu@YOUR_EC2_PUBLIC_IP        Enter..."
published: 2026-05-12
source: "https://dev.to/jumptotech/how-to-install-prometheus-39oc"
tags: []
---

# how to install prometheus


# 1. Connect to Ubuntu EC2

```bash
ssh -i your-key.pem ubuntu@YOUR_EC2_PUBLIC_IP
```

# 2. Update server

```bash
sudo apt update -y
sudo apt install wget tar -y
```

# 3. Create Prometheus user

```bash
sudo useradd --no-create-home --shell /bin/false prometheus
```

# 4. Create folders

```bash
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
```

# 5. Download Prometheus

```bash
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v3.5.3/prometheus-3.5.3.linux-amd64.tar.gz
```

# 6. Extract file

```bash
tar -xvf prometheus-3.5.3.linux-amd64.tar.gz
cd prometheus-3.5.3.linux-amd64
```

# 7. Move files

```bash
sudo cp prometheus /usr/local/bin/
sudo cp promtool /usr/local/bin/
sudo cp -r consoles /etc/prometheus
sudo cp -r console_libraries /etc/prometheus
sudo cp prometheus.yml /etc/prometheus/
```

# 8. Set permissions

```bash
sudo chown -R prometheus:prometheus /etc/prometheus
sudo chown -R prometheus:prometheus /var/lib/prometheus
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool
```

# 9. Create service file

```bash
sudo nano /etc/systemd/system/prometheus.service
```

Paste this:

```ini
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple

ExecStart=/usr/local/bin/prometheus \
 --config.file=/etc/prometheus/prometheus.yml \
 --storage.tsdb.path=/var/lib/prometheus \
 --web.console.templates=/etc/prometheus/consoles \
 --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
```

Save:

```text
CTRL + O
Enter
CTRL + X
```

# 10. Start Prometheus

```bash
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus
```

# 11. Check status

```bash
sudo systemctl status prometheus
```

You should see:

```text
active (running)
```

# 12. Open port 9090 in AWS

Go to:

```text
EC2 → Security Groups → Inbound rules → Edit inbound rules
```

Add:

```text
Type: Custom TCP
Port: 9090
Source: My IP
```

# 13. Open Prometheus in browser

```text
http://YOUR_EC2_PUBLIC_IP:9090
```

# 14. Test query

In Prometheus search box, type:

```promql
up
```

Click **Execute**.

If you see value `1`, Prometheus is working.

[1]: https://prometheus.io/download/?utm_source=chatgpt.com "Download | Prometheus"

