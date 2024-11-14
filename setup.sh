#!/bin/bash

LOG_FILE=~/install_log.txt

echo "Starting Docker installation..." | tee -a $LOG_FILE
sudo apt-get update -v -y >> $LOG_FILE 2>&1
sudo apt-get install -v -y docker.io docker-compose >> $LOG_FILE 2>&1

echo "image: ${DOCKER_USERNAME}/ci-cd-webcounter-backend:${RELEASE_TAG}" | tee -a $LOG_FILE
echo "image: ${DOCKER_USERNAME}/ci-cd-webcounter-frontend:${RELEASE_TAG}" | tee -a $LOG_FILE

echo "Running Docker Compose..." | tee -a $LOG_FILE
sudo docker-compose -f ~/docker-compose.yaml up -d >> $LOG_FILE 2>&1

echo "Checking if the application is up on port 80..." | tee -a $LOG_FILE
if curl --output /dev/null --silent --head --fail http://localhost:80/api/pressed; then
    echo "Application is up and running on port 80!" | tee -a $LOG_FILE
else
    echo "Application failed to start. Check logs for details." | tee -a $LOG_FILE
fi

cat $LOG_FILE
