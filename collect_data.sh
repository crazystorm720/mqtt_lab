#!/bin/bash
BROKER_IP=$1
mosquitto_sub -h $BROKER_IP -t "sensors/data" | tee -a /data/data.log
