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

3. **Check the collected data file** to ensure data is being logged:
    ```sh
    cat ./data/data.log
    ```

### Summary

1. **Project Setup**: Set up the directory structure and files.
2. **Dockerfiles**: Create Dockerfiles for the publisher and subscriber.
3. **MQTT Scripts**: Create scripts for generating and collecting data.
4. **Mosquitto Configuration**: Configure Mosquitto for remote access.
5. **Docker Compose**: Create and configure Docker Compose file.
6. **Build and Start**: Build images and start containers.
7. **Verify**: Check logs and data flow to ensure everything is working.


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
└── subscriber.sh
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

while true; do
  # Simulate real-world data (e.g., temperature and humidity)
  TEMP=$((RANDOM % 30 + 10))
  HUM=$((RANDOM % 50 + 30))
  TIMESTAMP=$(date +%s)
  PAYLOAD="{\"timestamp\": \"$TIMESTAMP\", \"temperature\": $TEMP, \"humidity\": $HUM}"
  
  mosquitto_pub -h $BROKER_IP -t $TOPIC -m "$PAYLOAD"
  sleep 1
done
```

#### Step 4: Create MQTT Subscriber Script

**subscriber.sh:**
```sh
#!/bin/bash
BROKER_IP=${BROKER_IP:-mqtt-broker}
TOPIC=${TOPIC:-sensors/data}

mosquitto_sub -h $BROKER_IP -t $TOPIC | tee -a /data/data.log
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
version: '3.8'

services:
  mqtt-broker:
    image: eclipse-mosquitto
    ports:
      - "1883:1883"
    volumes:
      - ./mosquitto.conf:/mosquitto/config/mosquitto.conf

  mqtt-publisher:
    build:
      context: .
      dockerfile: Dockerfile.publisher
    environment:
      - BROKER_IP=mqtt-broker
      - TOPIC=sensors/data
    depends_on:
      - mqtt-broker
    deploy:
      replicas: 3

  mqtt-subscriber:
    build:
      context: .
      dockerfile: Dockerfile.subscriber
    environment:
      - BROKER_IP=mqtt-broker
      - TOPIC=sensors/data
    depends_on:
      - mqtt-broker
    volumes:
      - ./data:/data
```
