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

podman pod exists $POD_NAME 
FLAGA=$?
if [ $FLAGA -eq 0 ]; then
echo "Pod called $POD_NAME exists in local storage" 
podman pod rm -f $POD_NAME
echo "Wait 2s..."
sleep 2
fi

DIR_PARENT="$HOME/public_html/wordpress"
DIR_A="$DIR_PARENT/mysql"
DIR_B="$DIR_PARENT/html"

if [ -d "$DIR_PARENT" ]; then
  echo "I'm deleting the directory: $DIR_PARENT"
  #sudo rm -rf "$DIR_PARENT"
  mkdir -p "$DIR_A"
  sudo chown -R 100998:100998 "$DIR_A"
  mkdir -p "$DIR_B"
  sudo chown -R 100032:100032 "$DIR_B"
  else
  echo "I create the necessary directories"
  mkdir -p "$DIR_A"
  sudo chown -R 100998:100998 "$DIR_A"
  mkdir -p "$DIR_B"
  sudo chown -R 100032:100032 "$DIR_B"
  fi

podman pod create --name "$POD_NAME" -p "$WP_PORT":80 -p $DB_PORT:3306 
echo "Wait 2s..."
sleep 2

podman run -d \
--restart=always --pod="$POD_NAME" \
-v "$DIR_A":/var/lib/mysql:Z \
-e MYSQL_ROOT_PASSWORD="$DB_ROOT_PW" \
-e MYSQL_DATABASE="$DB_NAME" \
-e MYSQL_USER="$DB_USER" \
-e MYSQL_PASSWORD="$DB_PASS" \
--name="$MARIADB_C_NAME" \
docker.io/library/mariadb:latest 

podman run -d \
--restart=always --pod="$POD_NAME" \
-v "$DIR_B":/var/www/html:Z \
-e WORDPRESS_DB_NAME="$DB_NAME" \
-e WORDPRESS_DB_USER="$DB_USER" \
-e WORDPRESS_DB_PASSWORD="$DB_PASS" \
-e WORDPRESS_DB_HOST="127.0.0.1:3306" \
--name="$WORDPRESS_C_NAME" \
docker.io/library/wordpress:latest 

podman pod list
podman ps -a
echo "Wait 4s..."
sleep 4
mysql -u"$DB_USER" -p"$DB_PASS" -h 127.0.0.1 -P $DB_PORT -e "SELECT @@version;"