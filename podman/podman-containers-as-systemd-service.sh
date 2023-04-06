#!/bin/sh

#podman-containers-as-systemd-service.sh
#based on:
#Daniel Walsh PODMAN IN ACTION

sudo loginctl enable-linger $(whoami)

sudo firewall-cmd --permanent --add-port=50080/tcp
sudo firewall-cmd --reload
sudo firewall-cmd --list-all | grep 50080

dir_A=($HOME'/www-data/example01')
if [ ! -d $dir_A ]; then
mkdir -pv $dir_A
fi
echo "Goodbye World" > ~/www-data/example01/index.html

podman run -d --name=apaczu-con -p 50080:8080 \
-v ~/www-data/example01:/var/www/html:ro,Z registry.access.redhat.com/ubi8/httpd-24
podman ps -l

dir_B=($HOME'/.config/systemd/user')
if [ ! -d $dir_B ]; then
mkdir -pv $dir_B
fi 
podman generate systemd --name apaczu-con > ~/.config/systemd/user/marcin-apacz.service
podman stop apaczu-con

systemctl --user daemon-reload
systemctl --user enable --now marcin-apacz.service
systemctl --user --no-pager status marcin-apacz.service
curl -v http://127.0.0.1:50080
