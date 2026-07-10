# Apache Kafka KRaft Mode (No ZooKeeper)

## Overview

Starting with modern Kafka versions, Apache Kafka can run in **KRaft (Kafka Raft Metadata) mode**, eliminating the need for ZooKeeper.

### Traditional Architecture

```text
+------------+
| ZooKeeper  |
+------------+
      |
      |
+------------+
|   Kafka    |
+------------+
```

### KRaft Architecture

```text
+----------------------+
|       Kafka          |
|  Broker + Controller |
|      (Raft)          |
+----------------------+
```

### Benefits of KRaft

* No ZooKeeper dependency
* Simpler deployment and maintenance
* Faster startup
* Reduced operational overhead
* Better scalability
* Future-proof architecture (recommended by Apache Kafka)

---

# Prerequisites

Before starting, ensure:

* Java is installed
* Kafka is downloaded and extracted
* Kafka version supports KRaft mode (Kafka 3.x+)

Verify Kafka installation:

```bash
kafka-topics.sh --version
```

---

# Step 1: Create a Data Directory

Kafka needs a location to store:

* Topics
* Partitions
* Messages
* Metadata logs

Create a directory:

```bash
mkdir -p data/kafka-kraft
```

Directory structure:

```text
project/
│
├── config/
├── bin/
└── data/
    └── kafka-kraft/
```

---

# Step 2: Configure Kafka Storage Location

Open the KRaft configuration file:

```bash
vi config/kraft/server.properties
```

Locate:

```properties
log.dirs=
```

Update it:

```properties
log.dirs=/your/path/data/kafka-kraft
```

Example:

```properties
log.dirs=/home/user/kafka/data/kafka-kraft
```

### Why?

Kafka stores:

* Topic data
* Partition logs
* Metadata snapshots
* Cluster information

inside this directory.

---

# Step 3: Generate a Kafka Cluster ID

Every KRaft cluster requires a unique identifier.

Generate one:

```bash
kafka-storage.sh random-uuid
```

Example output:

```text
76BLQI7sT_ql1mBfKsOk9Q
```

Save this value.

Example:

```bash
export CLUSTER_ID=76BLQI7sT_ql1mBfKsOk9Q
```

---

# Step 4: Format the Storage Directory

Initialize Kafka metadata storage:

```bash
kafka-storage.sh format \
-t $CLUSTER_ID \
-c config/kraft/server.properties
```

Example:

```bash
kafka-storage.sh format \
-t 76BLQI7sT_ql1mBfKsOk9Q \
-c config/kraft/server.properties
```

### What Happens Internally?

Kafka creates metadata files:

```text
data/kafka-kraft/
├── bootstrap.checkpoint
├── meta.properties
└── __cluster_metadata-0
```

Example `meta.properties`:

```properties
cluster.id=76BLQI7sT_ql1mBfKsOk9Q
node.id=1
version=1
```

### Important

Formatting should be performed **only once** for a new cluster.

Running it again may erase existing metadata.

---

# Step 5: Start Kafka

Start the Kafka broker:

```bash
kafka-server-start.sh config/kraft/server.properties
```

Expected logs:

```text
[KafkaServer id=1] started
```

or

```text
Kafka Server started
```

Kafka is now running.

Keep this terminal open.

---

# Understanding Kafka Roles

In KRaft mode, Kafka can perform two roles.

## Broker

Responsible for:

* Producing messages
* Consuming messages
* Managing topics
* Managing partitions

## Controller

Responsible for:

* Metadata management
* Leader election
* Cluster coordination
* Partition assignments

Configuration example:

```properties
process.roles=broker,controller
```

For local development, one node usually performs both roles.

---

# Verify Kafka Is Running

Create a test topic:

```bash
kafka-topics.sh \
--bootstrap-server localhost:9092 \
--create \
--topic test-topic \
--partitions 1 \
--replication-factor 1
```

List topics:

```bash
kafka-topics.sh \
--bootstrap-server localhost:9092 \
--list
```

Expected output:

```text
test-topic
```

---

# Test a Producer

Open a new terminal:

```bash
kafka-console-producer.sh \
--bootstrap-server localhost:9092 \
--topic test-topic
```

Send messages:

```text
Hello Kafka
Welcome to KRaft mode
```

---

# Test a Consumer

Open another terminal:

```bash
kafka-console-consumer.sh \
--bootstrap-server localhost:9092 \
--topic test-topic \
--from-beginning
```

Expected output:

```text
Hello Kafka
Welcome to KRaft mode
```

---

# KRaft Startup Workflow

```text
1. Create data directory
        |
        v
2. Configure log.dirs
        |
        v
3. Generate Cluster ID
        |
        v
4. Format Storage
        |
        v
5. Start Kafka
        |
        v
6. Create Topics
        |
        v
7. Produce & Consume Messages
```

---

# Common Commands

## Generate Cluster ID

```bash
kafka-storage.sh random-uuid
```

## Format Storage

```bash
kafka-storage.sh format \
-t <cluster-id> \
-c config/kraft/server.properties
```

## Start Kafka

```bash
kafka-server-start.sh config/kraft/server.properties
```

## Stop Kafka

```bash
Ctrl + C
```

## Create Topic

```bash
kafka-topics.sh \
--bootstrap-server localhost:9092 \
--create \
--topic my-topic
```

## List Topics

```bash
kafka-topics.sh \
--bootstrap-server localhost:9092 \
--list
```

---

# Traditional Kafka vs KRaft

| Feature            | ZooKeeper Mode    | KRaft Mode  |
| ------------------ | ----------------- | ----------- |
| ZooKeeper Required | Yes               | No          |
| Components         | Kafka + ZooKeeper | Kafka Only  |
| Complexity         | Higher            | Lower       |
| Startup Time       | Slower            | Faster      |
| Management         | More Complex      | Simpler     |
| Future Support     | Deprecated        | Recommended |

---

# Summary

KRaft mode is the modern way to run Apache Kafka.

The setup process consists of:

1. Creating a storage directory
2. Configuring `log.dirs`
3. Generating a Cluster ID
4. Formatting storage
5. Starting Kafka
6. Creating topics
7. Producing and consuming messages

With KRaft mode, Kafka manages its own metadata using the Raft consensus protocol, removing the need for ZooKeeper and simplifying cluster operations.
