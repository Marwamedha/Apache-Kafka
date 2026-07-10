# Kafka Console Producer Guide

## Overview

The **Kafka Console Producer** is a command-line tool used to send messages to Kafka topics.

It is useful for:

* Testing Kafka clusters
* Learning Kafka fundamentals
* Sending sample messages
* Debugging producers
* Verifying topic configurations

---

# Kafka Producer Command

Depending on your operating system, the command may vary:

| Environment                  | Command                         |
| ---------------------------- | ------------------------------- |
| Linux / macOS                | `kafka-console-producer.sh`     |
| Windows                      | `kafka-console-producer.bat`    |
| PATH Configured              | `kafka-console-producer`        |
| Kafka Home Not Added to PATH | `bin/kafka-console-producer.sh` |

Verify the command:

```bash
kafka-console-producer.sh
```

---

# Producer Fundamentals

A producer sends records to Kafka topics.

```text
Producer
    |
    v
+-----------+
|   Topic   |
+-----------+
    |
    v
Partitions
```

Each message contains:

```text
Key (Optional)
Value (Required)
Timestamp (Automatic)
```

Example:

```text
Key   = user123
Value = Order Created
```

---

# Using Conduktor Playground

## Step 1: Create a Topic

Before producing messages, create a topic.

```bash
kafka-topics.sh \
--command-config playground.config \
--bootstrap-server cluster.playground.cdkt.io:9092 \
--topic first_topic \
--create \
--partitions 1
```

---

## Step 2: Produce Messages

```bash
kafka-console-producer.sh \
--producer.config playground.config \
--bootstrap-server cluster.playground.cdkt.io:9092 \
--topic first_topic
```

The producer enters interactive mode:

```text
>
```

Type messages:

```text
>Hello World
>My name is Conduktor
>I love Kafka
```

Exit:

```text
Ctrl + C
```

---

## Step 3: Produce Messages with Acknowledgments

```bash
kafka-console-producer.sh \
--producer.config playground.config \
--bootstrap-server cluster.playground.cdkt.io:9092 \
--topic first_topic \
--producer-property acks=all
```

Send messages:

```text
> some message that is acked
> just for fun
> fun learning!
```

### What is `acks=all`?

The producer waits until all in-sync replicas acknowledge the message.

```text
Producer
    |
    v
Leader Replica
    |
    +----> Replica 1
    |
    +----> Replica 2
```

Only after all replicas confirm receipt does Kafka acknowledge the write.

Benefits:

* Maximum durability
* Highest reliability
* Reduced risk of data loss

---

# Producing to a Non-Existing Topic

```bash
kafka-console-producer.sh \
--producer.config playground.config \
--bootstrap-server cluster.playground.cdkt.io:9092 \
--topic new_topic
```

Send a message:

```text
> hello world!
```

Check existing topics:

```bash
kafka-topics.sh \
--command-config playground.config \
--bootstrap-server cluster.playground.cdkt.io:9092 \
--list
```

### Important

Conduktor Playground disables automatic topic creation.

Therefore:

```text
Producer -> Topic Does Not Exist
```

Result:

```text
Topic is NOT created automatically
```

Best practice:

Always create topics before producing messages.

---

# Producing Messages with Keys

Kafka supports key-value messages.

Start the producer:

```bash
kafka-console-producer.sh \
--producer.config playground.config \
--bootstrap-server cluster.playground.cdkt.io:9092 \
--topic first_topic \
--property parse.key=true \
--property key.separator=:
```

Send messages:

```text
>example_key:example value
>name:Stephane
```

Result:

```text
Key   = example_key
Value = example value

Key   = name
Value = Stephane
```

---

# Why Use Message Keys?

Keys determine which partition receives a message.

Example:

```text
Key = user1
```

Hash calculation:

```text
hash(user1) % number_of_partitions
```

Messages with the same key always go to the same partition.

Example:

```text
user1 -> Partition 0
user1 -> Partition 0
user1 -> Partition 0
```

Benefits:

* Preserves ordering
* Groups related records
* Enables stateful processing

---

# Using Local Kafka

Default Kafka endpoint:

```text
localhost:9092
```

---

# Create a Topic

```bash
kafka-topics.sh \
--bootstrap-server localhost:9092 \
--topic first_topic \
--create \
--partitions 1
```

---

# Produce Messages

```bash
kafka-console-producer.sh \
--bootstrap-server localhost:9092 \
--topic first_topic
```

Send:

```text
>Hello World
>My name is Kafka
>I love Kafka
```

Exit:

```text
Ctrl + C
```

---

# Produce with Acknowledgments

```bash
kafka-console-producer.sh \
--bootstrap-server localhost:9092 \
--topic first_topic \
--producer-property acks=all
```

Example:

```text
> some message that is acked
> just for fun
> fun learning!
```

---

# Auto Topic Creation Example

Produce to a topic that doesn't exist:

```bash
kafka-console-producer.sh \
--bootstrap-server localhost:9092 \
--topic new_topic
```

Send:

```text
> hello world!
```

Check topics:

```bash
kafka-topics.sh \
--bootstrap-server localhost:9092 \
--list
```

Describe the topic:

```bash
kafka-topics.sh \
--bootstrap-server localhost:9092 \
--topic new_topic \
--describe
```

Example output:

```text
Topic: new_topic
PartitionCount: 1
ReplicationFactor: 1
```

---

# Default Number of Partitions

Kafka automatically creates topics using:

```properties
num.partitions=1
```

Configuration file:

```text
config/server.properties
```

or

```text
config/kraft/server.properties
```

---

# Change Default Partitions

Edit:

```properties
num.partitions=3
```

Restart Kafka.

---

# Auto-Created Topic with 3 Partitions

Produce again:

```bash
kafka-console-producer.sh \
--bootstrap-server localhost:9092 \
--topic new_topic_2
```

Send:

```text
hello again!
```

Describe the topic:

```bash
kafka-topics.sh \
--bootstrap-server localhost:9092 \
--topic new_topic_2 \
--describe
```

Example:

```text
Topic: new_topic_2
PartitionCount: 3
ReplicationFactor: 1
```

---

# Produce with Keys (Local Kafka)

```bash
kafka-console-producer.sh \
--bootstrap-server localhost:9092 \
--topic first_topic \
--property parse.key=true \
--property key.separator=:
```

Send:

```text
>example_key:example value
>name:Stephane
```

Kafka stores:

```text
Key   = example_key
Value = example value

Key   = name
Value = Stephane
```

---

# Producer Best Practices

## Create Topics Explicitly

Avoid relying on automatic topic creation.

Recommended:

```bash
kafka-topics.sh --create ...
```

instead of:

```text
Producer -> Unknown Topic
```

---

## Use Keys When Ordering Matters

Example:

```text
customer_1001
customer_1001
customer_1001
```

All records stay in the same partition.

---

## Use `acks=all` for Reliability

```bash
--producer-property acks=all
```

Provides maximum durability and fault tolerance.

---

## Plan Partitions in Advance

Think about:

* Throughput requirements
* Number of consumers
* Scalability goals

Changing partitions later can impact message distribution.

---

# Common Producer Commands

| Action                 | Command                                                                        |
| ---------------------- | ------------------------------------------------------------------------------ |
| Start Producer         | `kafka-console-producer.sh --bootstrap-server localhost:9092 --topic my_topic` |
| Use Acknowledgments    | `--producer-property acks=all`                                                 |
| Send Key-Value Records | `--property parse.key=true --property key.separator=:`                         |
| Connect Securely       | `--producer.config playground.config`                                          |

---

# Summary

The Kafka Console Producer is the simplest way to send data into Kafka.

Key concepts learned:

* Producing messages
* Topic creation requirements
* Acknowledgments (`acks=all`)
* Auto-created topics
* Key-value messages
* Partition routing
* Producer best practices

Understanding producers is fundamental because every Kafka application begins by publishing messages into topics.
