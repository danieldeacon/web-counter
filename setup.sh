#!/bin/bash

LOG_FILE=~/install_log.txt

echo "Starting Docker installation..." | tee -a $LOG_FILE
sudo apt-get update -y >> $LOG_FILE 2>&1
sudo apt-get install -y docker.io docker-compose >> $LOG_FILE 2>&1

echo "Replacing placeholders in docker-compose.yaml..." | tee -a $LOG_FILE
sed -i "s|\${DOCKER_USERNAME}|${DOCKER_USERNAME}|g" ~/docker-compose.yaml >> $LOG_FILE 2>&1
sed -i "s|\${RELEASE_TAG}|${RELEASE_TAG}|g" ~/docker-compose.yaml >> $LOG_FILE 2>&1

echo "Running Docker Compose..." | tee -a $LOG_FILE
sudo docker-compose -f ~/docker-compose.yaml up -d >> $LOG_FILE 2>&1

echo "Waiting for containers to be ready..." | tee -a $LOG_FILE
until curl -s --head --request GET http://localhost:80 | grep "200 OK" > /dev/null; do
  echo "Waiting for the application to be available on port 80..." | tee -a $LOG_FILE
  sleep 5
done

echo "Application is up and running on port 80!" | tee -a $LOG_FILE

cat $LOG_FILE
