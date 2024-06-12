#!/bin/bash
BROKER_IP=${BROKER_IP:-mqtt-broker}
TOPIC=${TOPIC:-sensors/data}

while true; do
  # Simulate real-world data (e.g., temperature and humidity with variability)
  TEMP=$((RANDOM % 15 + 15))
  HUM=$((RANDOM % 20 + 40))
  TIMESTAMP=$(date +%s)
  PAYLOAD="{\"timestamp\": \"$TIMESTAMP\", \"temperature\": $TEMP, \"humidity\": $HUM}"

  mosquitto_pub -h $BROKER_IP -t $TOPIC -m "$PAYLOAD"
  sleep 1
done

