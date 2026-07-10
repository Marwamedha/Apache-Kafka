# Kafka Topics CLI Guide

## Kafka CLI Command Naming

Depending on your operating system and Kafka installation, the command may vary:

| Environment                  | Command                                                 |
| ---------------------------- | ------------------------------------------------------- |
| Linux / macOS                | `kafka-topics.sh`                                       |
| Windows                      | `kafka-topics.bat`                                      |
| PATH Configured              | `kafka-topics`                                          |
| Kafka Home Not Added to PATH | `bin/kafka-topics.sh` or `bin\windows\kafka-topics.bat` |

---

# Working with Conduktor Playground

## Step 1: Create Configuration File

Create a file named:

```text
playground.config
```

Add the following content:

```properties
security.protocol=SASL_SSL
sasl.mechanism=PLAIN
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="<your_username>" password="<your_password>";
```

### Purpose

This file stores authentication information so Kafka CLI tools can securely connect to the Conduktor Playground cluster.

---

## Step 2: Verify Kafka Topics Command

Check whether the Kafka Topics CLI is available:

```bash
kafka-topics.sh
```

---

## Step 3: Connect to the Cluster

```bash
kafka-topics.sh \
--command-config playground.config \
--bootstrap-server cluster.playground.cdkt.io:9092
```

### Parameters

| Parameter            | Description                  |
| -------------------- | ---------------------------- |
| `--command-config`   | Authentication configuration |
| `--bootstrap-server` | Kafka broker address         |

---

# Create Topics

## Create a Topic with Default Settings

```bash
kafka-topics.sh \
--command-config playground.config \
--bootstrap-server cluster.playground.cdkt.io:9092 \
--create \
--topic first_topic
```

---

## Create a Topic with Multiple Partitions

```bash
kafka-topics.sh \
--command-config playground.config \
--bootstrap-server cluster.playground.cdkt.io:9092 \
--create \
--topic second_topic \
--partitions 5
```

### Result

```text
Topic Name : second_topic
Partitions : 5
```

Increasing partitions improves parallelism and throughput.

---

## Create a Topic with Replication

```bash
kafka-topics.sh \
--command-config playground.config \
--bootstrap-server cluster.playground.cdkt.io:9092 \
--create \
--topic third_topic \
--replication-factor 2
```

### Replication Factor (RF)

Replication provides fault tolerance.

Example:

```text
Partition 0
├── Broker 1 (Leader)
└── Broker 2 (Replica)
```

> Note: In Conduktor Playground, topics are typically created with a default replication factor of 3 regardless of the specified value.

---

# List Topics

Display all available topics:

```bash
kafka-topics.sh \
--command-config playground.config \
--bootstrap-server cluster.playground.cdkt.io:9092 \
--list
```

Example output:

```text
first_topic
second_topic
third_topic
```

---

# Describe a Topic

View detailed information:

```bash
kafka-topics.sh \
--command-config playground.config \
--bootstrap-server cluster.playground.cdkt.io:9092 \
--topic first_topic \
--describe
```

Example output:

```text
Topic: first_topic
PartitionCount: 1
ReplicationFactor: 3
Configs:
```

This command shows:

* Number of partitions
* Replication factor
* Leader broker
* Replica brokers
* Topic configuration

---

# Delete a Topic

```bash
kafka-topics.sh \
--command-config playground.config \
--bootstrap-server cluster.playground.cdkt.io:9092 \
--topic second_topic \
--delete
```

After deletion:

```text
Topic second_topic marked for deletion
```

---

# Working with Local Kafka

When Kafka is running locally, no authentication file is needed.

Default Kafka endpoint:

```text
localhost:9092
```

---

# List Topics

```bash
kafka-topics.sh \
--bootstrap-server localhost:9092 \
--list
```

---

# Create Topics

## Single Partition Topic

```bash
kafka-topics.sh \
--bootstrap-server localhost:9092 \
--topic first_topic \
--create
```

Default:

```text
Partitions = 1
Replication Factor = 1
```

---

## Topic with Three Partitions

```bash
kafka-topics.sh \
--bootstrap-server localhost:9092 \
--topic second_topic \
--create \
--partitions 3
```

Result:

```text
Topic: second_topic
Partitions: 3
```

---

## Topic with Replication Factor 2

```bash
kafka-topics.sh \
--bootstrap-server localhost:9092 \
--topic third_topic \
--create \
--partitions 3 \
--replication-factor 2
```

### Important

This command requires at least **two Kafka brokers**.

Otherwise, Kafka returns:

```text
Replication factor: 2 larger than available brokers: 1
```

---

## Single-Broker Environment (Working Example)

For local KRaft or single-node Kafka:

```bash
kafka-topics.sh \
--bootstrap-server localhost:9092 \
--topic third_topic \
--create \
--partitions 3 \
--replication-factor 1
```

This is the recommended configuration for local development.

---

# Describe a Topic

```bash
kafka-topics.sh \
--bootstrap-server localhost:9092 \
--topic first_topic \
--describe
```

Example output:

```text
Topic: first_topic
PartitionCount: 1
ReplicationFactor: 1
```

---

# Delete a Topic

```bash
kafka-topics.sh \
--bootstrap-server localhost:9092 \
--topic first_topic \
--delete
```

### Requirement

Topic deletion only works when Kafka is configured with:

```properties
delete.topic.enable=true
```

inside:

```text
config/server.properties
```

or

```text
config/kraft/server.properties
```

---

# Understanding Key Concepts

## Topic

A logical container for messages.

```text
Orders Topic
├── Order 1
├── Order 2
└── Order 3
```

---

## Partition

A topic is divided into partitions.

```text
orders
├── Partition 0
├── Partition 1
└── Partition 2
```

Benefits:

* Parallel processing
* Higher throughput
* Better scalability

---

## Replication Factor

Determines how many copies of data exist.

Example:

```text
Replication Factor = 3

Broker 1 → Leader
Broker 2 → Replica
Broker 3 → Replica
```

Benefits:

* Fault tolerance
* High availability
* Data durability

---

# Common Kafka Topics Commands

| Action                  | Command                                                                                                             |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------- |
| List Topics             | `kafka-topics.sh --bootstrap-server localhost:9092 --list`                                                          |
| Create Topic            | `kafka-topics.sh --bootstrap-server localhost:9092 --create --topic my_topic`                                       |
| Describe Topic          | `kafka-topics.sh --bootstrap-server localhost:9092 --describe --topic my_topic`                                     |
| Delete Topic            | `kafka-topics.sh --bootstrap-server localhost:9092 --delete --topic my_topic`                                       |
| Create Partitions       | `kafka-topics.sh --bootstrap-server localhost:9092 --create --topic my_topic --partitions 3`                        |
| Create Replicated Topic | `kafka-topics.sh --bootstrap-server localhost:9092 --create --topic my_topic --partitions 3 --replication-factor 2` |

---

# Summary

The `kafka-topics` command is the primary Kafka administration tool used to:

* Create topics
* Delete topics
* List topics
* Inspect topic metadata
* Configure partitions
* Configure replication

Understanding partitions and replication is essential because they directly affect Kafka scalability, performance, and fault tolerance.
