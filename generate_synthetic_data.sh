#!/bin/bash
BROKER_IP=$1
while true; do
  PAYLOAD="sensor_value: $((RANDOM % 100))"
  mosquitto_pub -h $BROKER_IP -t "sensors/data" -m "$PAYLOAD"
  sleep 1
done
