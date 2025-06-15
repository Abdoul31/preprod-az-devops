###VARIABLES DE CONFIG POSTGRE
NETWORK_NAME="nextcloud-net"
POSTGRES_CONTAINER="nextcloud-db"
POSTGRES_DB="nextcloud"
POSTGRES_USER="ncuser"
POSTGRES_PASSWORD="add@1718"

CPU_LIMIT="0.5"        
CPU_SHARES="512"

echo "Deploiement du conteneur PostgreSQL sur le reseau $NETWORK_NAME"

docker run -d \
--name $POSTGRES_CONTAINER \
--network $NETWORK_NAME \
--cpus="$CPU_LIMIT" \
--cpu-shares="$CPU_SHARES \
-e POSTGRES_DB=$POSTGRES_DB \
-e POSTGRES_USER=$POSTGRES_USER \
-e POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
-v extcloud-db-data:/var/lib/postgresql/data \
postgres:15
echo "postgreSQL deploye dans le conteneur $POSTGRES_CONTAINER"
