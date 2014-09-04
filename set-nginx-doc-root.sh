#!/bin/bash

SITE_NAME=example.theteamie.com
DOC_ROOT=/var/www/drupal
NGINX_CONF_LOCATION=/etc/nginx/sites-available/local
NGINX_BINARY_LOCATION=/root/downloads/nginx-1.5.6/objs/nginx

echo -e "
server { 
  listen 80;
  server_name $SITE_NAME; 
  root $DOC_ROOT;
  index index.html index.htm;
  access_log /var/log/nginx/${SITE_NAME}_access.log;
  error_log /var/log/nginx/${SITE_NAME}_error.log;
  include /etc/nginx/denyhost.conf; 
  include /etc/nginx/apps/drupal/drupal.conf; 
}

server {
  listen 443 ssl;
  server_name $SITE_NAME;
  root $DOC_ROOT;
  index index.html index.htm;
  access_log /var/log/nginx/${SITE_NAME}_access.log;
  error_log /var/log/nginx/${SITE_NAME}_error.log;
  include /etc/nginx/denyhost.conf;
  include /etc/nginx/apps/drupal/drupal.conf;
}" > "$NGINX_CONF_LOCATION/$SITE_NAME"

NGINX_CONF_ERROR=$($NGINX_BINARY_LOCATION -t > /dev/null 2>&1; echo $?)

echo "NGINX_CONF_ERROR $NGINX_CONF_ERROR" 

if [ $NGINX_CONF_ERROR -eq 1 ];then
  echo "Nginx configuration error! Please check the nginx configuration created at $NGINX_CONF_LOCATION/$SITE_NAME" 
  exit 1
else
  echo "Nginx configuration is okay !! Going to restart webserver" 
fi

## Restart nginx webserver 
sudo service nginx restart
#/root/bin/ngx


