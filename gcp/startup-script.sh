#!/bin/bash
wget -qO - https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable" | sudo tee /etc/apt/sources.list.d/docker.list
gcloud auth configure-docker europe-central2-docker.pkg.dev <<< -y
sudo apt update; sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
IMAGE=$(gcloud artifacts docker images list europe-central2-docker.pkg.dev/petclinic-444616/docker-image-registry/petclinic/  --include-tags --sort-by="~updateTime" --limit=1 --format='get(IMAGE)')
TAG="latest"
# TAG=$(gcloud artifacts docker images list europe-central2-docker.pkg.dev/petclinic-444616/docker-image-registry/petclinic/  --include-tags --sort-by="~updateTime" --limit=1 --format='get(TAGS)')
DB_ADDRESS="${db_ip}"
mkdir -p /home/bsc-node/petclinic/docker-compose
APP_DOCKER_COMPOSE_FILE=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/app_docker_compose)
echo "$APP_DOCKER_COMPOSE_FILE" > "/home/bsc-node/petclinic/docker-compose/docker-compose.yml"
echo "IMAGE='$IMAGE'" >> /home/bsc-node/petclinic/docker-compose/.env
echo "TAG='$TAG'" >> /home/bsc-node/petclinic/docker-compose/.env
echo "DB_ADDRESS='$DB_ADDRESS'" >> /home/bsc-node/petclinic/docker-compose/.env
cd /home/bsc-node/petclinic/docker-compose && docker compose up -d
chmod -R 755 /home/bsc-node/petclinic
chown -R  bsc-node:bsc-node /home/bsc-node/petclinic

# sudo docker run -d --rm -e POSTGRES_PASS=petclinic -e POSTGRES_USER=petclinic -e POSTGRES_DB=petclinic -e POSTGRES_URL="jdbc:postgresql://$db_address:5432/petclinic" -e SPRING_PROFILES_ACTIVE=postgres -p 80:8080 $IMAGE:$TAG

mkdir -p /home/bsc-node/monitoring 
CONFIG_PROMTAIL=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/promtail_config)
echo "$CONFIG_PROMTAIL" > "/home/bsc-node/monitoring/promtail.yml"
DOCKER_COMPOSE_FILE=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/monitoring_docker_compose)
echo "$DOCKER_COMPOSE_FILE" > "/home/bsc-node/monitoring/docker-compose.yml"
cd /home/bsc-node/monitoring && docker compose up -d
chmod -R 755 /home/bsc-node/monitoring
chown -R  bsc-node:bsc-node /home/bsc-node/monitoring