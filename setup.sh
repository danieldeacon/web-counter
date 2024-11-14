#!/bin/bash

# Create a log file
LOG_FILE=~/install_log.txt

# Install Docker and Docker Compose and capture the output
echo "Starting Docker installation..." | tee -a $LOG_FILE
sudo apt-get update -y >> $LOG_FILE 2>&1
sudo apt-get install -y docker.io docker-compose >> $LOG_FILE 2>&1

# Download docker-compose.yaml file and capture the output
echo "Downloading docker-compose.yaml..." | tee -a $LOG_FILE
wget https://raw.githubusercontent.com/${DOCKER_USERNAME}/web-counter/main/docker-compose.yaml -O ~/docker-compose.yaml >> $LOG_FILE 2>&1

# Replace placeholders in docker-compose.yaml and capture the output
echo "Replacing placeholders in docker-compose.yaml..." | tee -a $LOG_FILE
sed -i "s|\${DOCKER_USERNAME}|${DOCKER_USERNAME}|g" ~/docker-compose.yaml >> $LOG_FILE 2>&1
sed -i "s|\${RELEASE_TAG}|${RELEASE_TAG}|g" ~/docker-compose.yaml >> $LOG_FILE 2>&1

# Run Docker Compose and capture the output
echo "Running Docker Compose..." | tee -a $LOG_FILE
sudo docker-compose -f ~/docker-compose.yaml up -d >> $LOG_FILE 2>&1

# Wait for containers to be ready (check port 80) and capture the output
echo "Waiting for containers to be ready..." | tee -a $LOG_FILE
until curl -s --head --request GET http://localhost:80 | grep "200 OK" > /dev/null; do
  echo "Waiting for the application to be available on port 80..." | tee -a $LOG_FILE
  sleep 5
done

# Final output indicating the application is ready
echo "Application is up and running on port 80!" | tee -a $LOG_FILE

# Output the log contents (optional)
cat $LOG_FILE
