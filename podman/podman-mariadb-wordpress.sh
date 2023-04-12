#!/bin/bash
#podman-mariadb-wordpress.sh

POD_NAME='wordpress-mariadb'
MARIADB_C_NAME='mariadb-wordpress'
WORDPRESS_C_NAME='wordpress'
DB_ROOT_PW='pass'
DB_NAME='mariawordpress'
DB_USER='wordpress'
DB_PASS='pass'
WP_PORT=58080
DB_PORT=53306
dir_parent=$HOME'/public_html/wordpress'
dir_A=$HOME'/public_html/wordpress/mysql'
dir_B=$HOME'/public_html/wordpress/html'

podman pod exists $POD_NAME 
flaga=$?
if [ "$flaga" -eq 0 ]; then
echo "Pod called $POD_NAME exists in local storage" 
podman pod rm -f $POD_NAME
fi

if [ -d "$dir_parent" ]; then
sudo chown "$(whoami)" -R ~/public_html/
rm -rvf  ~/public_html/
else

	if [ ! -d "$dir_A" ]; then
	mkdir -pv "$dir_A"
	fi
	
	if [ ! -d "$dir_B" ]; then
	mkdir -pv "$dir_B"
	fi
fi

podman pod create --name $POD_NAME -p $WP_PORT:80 -p $DB_PORT:3306

podman run -d \
--restart=always --pod="$POD_NAME" \
-v "$dir_A":/var/lib/mysql:Z \
-e MYSQL_ROOT_PASSWORD="$DB_ROOT_PW" \
-e MYSQL_DATABASE="$DB_NAME" \
-e MYSQL_USER="$DB_USER" \
-e MYSQL_PASSWORD="$DB_PASS" \
--name="$MARIADB_C_NAME" \
docker.io/library/mariadb:latest

podman run -d \
--restart=always --pod="$POD_NAME" \
-v "$dir_B":/var/www/html:Z \
-e WORDPRESS_DB_NAME="$DB_NAME" \
-e WORDPRESS_DB_USER="$DB_USER" \
-e WORDPRESS_DB_PASSWORD="$DB_PASS" \
-e WORDPRESS_DB_HOST="127.0.0.1:3306" \
--name="$WORDPRESS_C_NAME" docker.io/library/wordpress:latest

podman pod list
podman ps -a
sleep 1
mysql -u"$DB_USER" -p"$DB_PASS" -h 127.0.0.1 -P "$DB_PORT" -e "SELECT @@version;"