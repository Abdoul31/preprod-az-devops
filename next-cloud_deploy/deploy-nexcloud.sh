#!/bin/bash

NETWORK_NAME="nextcloud-net"
NEXTCLOUD_CONTAINER="nextcloud-app"
POSTGRES_DB="nextcloud"
POSTGRES_USER="ncuser"
POSTGRES_PASSWORD="add@1718"
POSTGRES_HOST="nextcloud-db"

echo "deploiement du conteneur Nextcloud connecté à PostgreSQL"

docker run -d \
--name $NEXTCLOUD_CONTAINER \
--network $NETWORK_NAME \
-p 8080:80 \
-e POSTGRES_DB=$POSTGRES_DB \
-e POSTGRES_USER=$POSTGRES_USER \
-e POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
-e POSTGRES_HOST=$POSTGRES_HOST \
-v nextcloud-data:/var/www/html \
nextcloud

echo "Next-cloud est en cours d'execution sur le port 8080"