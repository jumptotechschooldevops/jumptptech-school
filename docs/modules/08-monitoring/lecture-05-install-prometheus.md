# How to Install Prometheus

#  1\. Connect to Ubuntu EC2 
[code] 
    ssh -i your-key.pem ubuntu@YOUR_EC2_PUBLIC_IP
    
[/code]

Enter fullscreen mode Exit fullscreen mode

#  2\. Update server 
[code] 
    sudo apt update -y
    sudo apt install wget tar -y
    
[/code]

Enter fullscreen mode Exit fullscreen mode

#  3\. Create Prometheus user 
[code] 
    sudo useradd --no-create-home --shell /bin/false prometheus
    
[/code]

Enter fullscreen mode Exit fullscreen mode

#  4\. Create folders 
[code] 
    sudo mkdir /etc/prometheus
    sudo mkdir /var/lib/prometheus
    
[/code]

Enter fullscreen mode Exit fullscreen mode

#  5\. Download Prometheus 
[code] 
    cd /tmp
    wget https://github.com/prometheus/prometheus/releases/download/v3.5.3/prometheus-3.5.3.linux-amd64.tar.gz
    
[/code]

Enter fullscreen mode Exit fullscreen mode

#  6\. Extract file 
[code] 
    tar -xvf prometheus-3.5.3.linux-amd64.tar.gz
    cd prometheus-3.5.3.linux-amd64
    
[/code]

Enter fullscreen mode Exit fullscreen mode

#  7\. Move files 
[code] 
    sudo cp prometheus /usr/local/bin/
    sudo cp promtool /usr/local/bin/
    sudo cp -r consoles /etc/prometheus
    sudo cp -r console_libraries /etc/prometheus
    sudo cp prometheus.yml /etc/prometheus/
    
[/code]

Enter fullscreen mode Exit fullscreen mode

#  8\. Set permissions 
[code] 
    sudo chown -R prometheus:prometheus /etc/prometheus
    sudo chown -R prometheus:prometheus /var/lib/prometheus
    sudo chown prometheus:prometheus /usr/local/bin/prometheus
    sudo chown prometheus:prometheus /usr/local/bin/promtool
    
[/code]

Enter fullscreen mode Exit fullscreen mode

#  9\. Create service file 
[code] 
    sudo nano /etc/systemd/system/prometheus.service
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Paste this:  

[code] 
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
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Save:  

[code] 
    CTRL + O
    Enter
    CTRL + X
    
[/code]

Enter fullscreen mode Exit fullscreen mode

#  10\. Start Prometheus 
[code] 
    sudo systemctl daemon-reload
    sudo systemctl start prometheus
    sudo systemctl enable prometheus
    
[/code]

Enter fullscreen mode Exit fullscreen mode

#  11\. Check status 
[code] 
    sudo systemctl status prometheus
    
[/code]

Enter fullscreen mode Exit fullscreen mode

You should see:  

[code] 
    active (running)
    
[/code]

Enter fullscreen mode Exit fullscreen mode

#  12\. Open port 9090 in AWS 

Go to:  

[code] 
    EC2 → Security Groups → Inbound rules → Edit inbound rules
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Add:  

[code] 
    Type: Custom TCP
    Port: 9090
    Source: My IP
    
[/code]

Enter fullscreen mode Exit fullscreen mode

#  13\. Open Prometheus in browser 
[code] 
    http://YOUR_EC2_PUBLIC_IP:9090
    
[/code]

Enter fullscreen mode Exit fullscreen mode

#  14\. Test query 

In Prometheus search box, type:  

[code] 
    up
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Click **Execute**.

If you see value `1`, Prometheus is working.
