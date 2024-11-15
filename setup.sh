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
sudo apt-get update -v -y >> $LOG_FILE 2>&1
sudo apt-get install -v -y docker.io docker-compose >> $LOG_FILE 2>&1

echo "Using backend image: ${DOCKER_USERNAME}/ci-cd-webcounter-backend:${RELEASE_TAG}" | tee -a $LOG_FILE
echo "Using frontend image: ${DOCKER_USERNAME}/ci-cd-webcounter-frontend:${RELEASE_TAG}" | tee -a $LOG_FILE

echo "-----COMPOSING CONTAINERS-----" | tee -a $LOG_FILE
sudo docker-compose -f ~/docker-compose.yaml up -d >> $LOG_FILE 2>&1

echo "Waiting for containers to initialize..." | tee -a $LOG_FILE
sleep 60

echo "-----TESTING APPLICATION-----" | tee -a $LOG_FILE
if curl --output /dev/null --silent --head --fail http://localhost:80/api/pressed; then
    echo "-----WEBCOUNTER ACTIVE-----" | tee -a $LOG_FILE
    echo $(curl http://localhost:80/api/pressed) | tee -a $LOG_FILE
    echo "-----REMOVING VARIABLES-----"
    rm -f /home/ubuntu/.env
    exit 0
else
    echo "-----WEBCOUNTER INACTIVE-----" | tee -a $LOG_FILE
    echo "Check the log file $LOG_FILE for details." | tee -a $LOG_FILE
    exit 1
fi

cat $LOG_FILE
