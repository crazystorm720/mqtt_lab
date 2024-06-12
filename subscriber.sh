#!/bin/bash
BROKER_IP=${BROKER_IP:-mqtt-broker}
TOPIC=${TOPIC:-sensors/data}

log_file="/data/data.log"

# Ensure the log file exists
touch $log_file

# Function to log messages
log() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a $log_file
}

log "Starting MQTT Subscriber"

/usr/bin/mosquitto_sub -h $BROKER_IP -t $TOPIC | while read -r message; do
  log "Received: $message"
done
