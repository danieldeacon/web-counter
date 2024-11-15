#!/bin/bash

LOG_FILE=/home/ubuntu/install_log.txt

if [ -f /home/ubuntu/.env ]; then
    echo "Sourcing environment variables from .env file..." | tee -a $LOG_FILE
    source /home/ubuntu/.env
else
    echo ".env file not found. Exiting..." | tee -a $LOG_FILE
    exit 1
fi

echo "-----INSTALLING DOCKER-----" | tee -a $LOG_FILE

for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do 
sudo apt-get remove $pkg -y; 
done | tee -a $LOG_FILE

sudo apt-get update -y | tee -a $LOG_FILE
sudo apt-get install ca-certificates curl -y | tee -a $LOG_FILE
sudo install -m 0755 -d /etc/apt/keyrings | tee -a $LOG_FILE
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc | tee -a $LOG_FILE
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null | tee -a $LOG_FILE
sudo apt-get update  -y | tee -a $LOG_FILE

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y | tee -a $LOG_FILE

echo "-----COMPOSING CONTAINERS-----" | tee -a $LOG_FILE
echo "Using backend image: ${DOCKER_USERNAME}/ci-cd-webcounter-backend:${RELEASE_TAG}" | tee -a $LOG_FILE
echo "Using frontend image: ${DOCKER_USERNAME}/ci-cd-webcounter-frontend:${RELEASE_TAG}" | tee -a $LOG_FILE
sudo docker compose -f /home/ubuntu/docker-compose.yaml up >> $LOG_FILE 2>&1

echo "Waiting for containers to initialize..." | tee -a $LOG_FILE
sleep 60

echo "-----TESTING APPLICATION-----" | tee -a $LOG_FILE

echo $(curl http://localhost:80) | tee -a $LOG_FILE
echo $(curl http://localhost:80/api/pressed) | tee -a $LOG_FILE
STATUS_CODE=$(curl --silent --output /dev/null --write-out "%{http_code}" http://localhost:80/api/pressed)
echo "Status Code: $STATUS_CODE" | tee -a $LOG_FILE

if [ "$STATUS_CODE" -eq 200 ]; then
    echo "-----WEBCOUNTER ACTIVE-----" | tee -a $LOG_FILE
    echo "-----REMOVING VARIABLES-----"
    rm -f /home/ubuntu/.env
    exit 0
else
    echo "Error: Webcounter is not active. Status code: $STATUS_CODE" | tee -a $LOG_FILE
    exit 1
fi

cat $LOG_FILE
