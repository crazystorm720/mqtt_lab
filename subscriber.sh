#!/bin/bash
BROKER_IP=${BROKER_IP:-mqtt-broker}
TOPIC=${TOPIC:-sensors/data}

mosquitto_sub -h $BROKER_IP -t $TOPIC | tee -a /data/data.log
