### Step-by-Step Guide

#### Step 1: Project Structure

Ensure you have the following directory structure:

```
mqtt_lab/
├── Dockerfile.publisher
├── Dockerfile.subscriber
├── docker-compose.yml
├── mosquitto.conf
├── publisher.sh
├── subscriber.sh
├── .env
└── data/
```

#### Step 2: Create Dockerfiles

**Dockerfile.publisher:**
```Dockerfile
FROM ubuntu:focal

RUN apt-get update && apt-get install -y mosquitto-clients

COPY publisher.sh /usr/local/bin/publisher.sh
RUN chmod +x /usr/local/bin/publisher.sh

CMD ["sh", "/usr/local/bin/publisher.sh"]
```

**Dockerfile.subscriber:**
```Dockerfile
FROM ubuntu:focal

RUN apt-get update && apt-get install -y mosquitto-clients

COPY subscriber.sh /usr/local/bin/subscriber.sh
RUN chmod +x /usr/local/bin/subscriber.sh

CMD ["sh", "/usr/local/bin/subscriber.sh"]
```

#### Step 3: Create MQTT Publisher Script

**publisher.sh:**
```sh
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
```

#### Step 4: Create MQTT Subscriber Script

**subscriber.sh:**
```sh
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

mosquitto_sub -h $BROKER_IP -t $TOPIC | while read -r message; do
  log "Received: $message"
done
```

#### Step 5: Create Mosquitto Configuration File

**mosquitto.conf:**
```conf
listener 1883
allow_anonymous true
```

#### Step 6: Create Docker Compose File

**docker-compose.yml:**
```yaml
version: '3.9'

services:
  mqtt-broker:
    image: eclipse-mosquitto
    ports:
      - "1883:1883"
    volumes:
      - ./mosquitto.conf:/mosquitto/config/mosquitto.conf
    healthcheck:
      test: ["CMD", "mosquitto_pub", "-h", "localhost", "-t", "health/check", "-m", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3

  mqtt-publisher:
    build:
      context: .
      dockerfile: Dockerfile.publisher
    environment:
      - BROKER_IP=${BROKER_IP}
      - TOPIC=${TOPIC}
    depends_on:
      - mqtt-broker
    deploy:
      replicas: 3
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  mqtt-subscriber:
    build:
      context: .
      dockerfile: Dockerfile.subscriber
    environment:
      - BROKER_IP=${BROKER_IP}
      - TOPIC=${TOPIC}
    depends_on:
      - mqtt-broker
    volumes:
      - ./data:/data
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

#### Step 7: Build and Start the Docker Containers

1. **Build the Docker images**:
    ```sh
    docker-compose build
    ```

2. **Start the Docker containers**:
    ```sh
    docker-compose up -d
    ```

#### Step 8: Verify MQTT Data Flow

1. **Check the broker logs** to ensure it is running correctly:
    ```sh
    docker-compose logs mqtt-broker
    ```

2. **Verify publishers are sending data**:
    ```sh
    docker-compose logs mqtt-publisher
    ```

3. **Verify the subscriber is collecting data**:
    ```sh
    docker-compose exec mqtt-subscriber cat /data/data.log
    ```

#### Step 9: Perform MQTT Verification Commands

1. **Publish a test message manually**:
    ```sh
    docker-compose exec mqtt-publisher mosquitto_pub -h mqtt-broker -t "sensors/data" -m "test message"
    ```

2. **Subscribe to the topic to see real-time data**:
    ```sh
    docker-compose exec mqtt-subscriber mosquitto_sub -h mqtt-broker -t "sensors/data"
    ```

3. **Check the collected data file** to ensure data is being logged**:
    ```sh
    cat ./data/data.log
    ```

### Cleanup and Maintenance

1. **Stop and Remove All Containers**:
    ```sh
    docker-compose down --volumes --remove-orphans
    ```

2. **Remove Any Remaining Containers**:
    ```sh
    docker ps -a
    docker rm -f <container_id>  # For any remaining containers
    ```

3. **Remove Any Remaining Networks**:
    ```sh
    docker network ls
    docker network rm <network_id>  # For any remaining networks
    ```

4. **Restart Services**:
    ```sh
    docker-compose up -d
    ```

These steps ensure a clean and maintainable project setup for your MQTT lab environment.
