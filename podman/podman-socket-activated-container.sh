#!/bin/sh

#podman-socket-activated-container.sh
#based on:
#Painless services: implementing serverless with rootless Podman and systemd 
#https://www.redhat.com/en/blog/painless-services-implementing-serverless-rootless-podman-and-systemd
#working principle:
#0.0.0.0 <--> marcin-httpd-proxy.socket <--> marcin-httpd-proxy.service <--> marcin-httpd.service <--> KONTENER

sudo loginctl enable-linger $(whoami)
systemctl --user enable --now podman.socket

sudo firewall-cmd --permanent --add-port=50082/tcp
sudo firewall-cmd --reload
sudo firewall-cmd --list-all | grep 50082

dir_A=($HOME'/www-data/example02')
if [ ! -d $dir_A ]; then
mkdir -pv $dir_A
fi 
echo "Page Under Mainteance" > ~/www-data/example02/index.html

podman create --name httpd -p 127.0.0.1:50082:8080 \
-v ~/www-data/example02:/var/www/html/:ro,Z registry.access.redhat.com/ubi8/httpd-24

dir_B=($HOME'/.config/systemd/user')
if [ ! -d $dir_B ]; then
mkdir -pv $dir_B
fi  
podman generate systemd --new --name httpd > ~/.config/systemd/user/marcin-httpd.service  

sed -i '32,33d' ~/.config/systemd/user/marcin-httpd.service
sed -i '11 i StopWhenUnneeded=yes' ~/.config/systemd/user/marcin-httpd.service 

cat << EOF > ~/.config/systemd/user/marcin-httpd-proxy.socket
[Socket]
ListenStream=192.168.122.3:50082

[Install]
WantedBy=sockets.target
EOF

cat << EOF > ~/.config/systemd/user/marcin-httpd-proxy.service 
[Unit]
Requires=marcin-httpd.service
After=marcin-httpd.service
Requires=marcin-httpd-proxy.socket
After=marcin-httpd-proxy.socket

[Service]
ExecStart=/usr/lib/systemd/systemd-socket-proxyd --exit-idle-time=30s 127.0.0.1:50082
EOF

systemctl --user daemon-reload
systemctl --user enable --now marcin-httpd-proxy.socket

