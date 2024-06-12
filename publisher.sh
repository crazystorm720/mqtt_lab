#!/bin/bash
BROKER_IP=${BROKER_IP:-mqtt-broker}
TOPIC=${TOPIC:-sensors/data}

log_file="/var/log/mqtt_publisher.log"

# Function to log messages
log() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a $log_file
}

log "Starting MQTT Publisher"

while true; do
  TEMP=$((RANDOM % 30 + 10))
  HUM=$((RANDOM % 50 + 30))
  TIMESTAMP=$(date +%s)
  PAYLOAD="{\"timestamp\": \"$TIMESTAMP\", \"temperature\": $TEMP, \"humidity\": $HUM}"
  
  mosquitto_pub -h $BROKER_IP -t $TOPIC -m "$PAYLOAD"
  if [ $? -eq 0 ]; then
    log "Published: $PAYLOAD"
  else
    log "Failed to publish: $PAYLOAD"
  fi
  sleep 1
done
