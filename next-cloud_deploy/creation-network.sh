#!/bin/bash
NETWORK_NAME="nextcloud-net"

echo "creation du reseau docker dedie nextcloud : $NETWORK_NAME"

# Création d'un réseau bridge Docker pour que les conteneurs puissent communiquer
docker network create $NETWORK_NAME

echo "reseau $NETWORK_NAME crée avec succès"
