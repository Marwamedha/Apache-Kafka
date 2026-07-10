# Kafka Console Consumer Guide

## Overview

The **Kafka Console Consumer** is a command-line tool used to read messages from Kafka topics.

It is commonly used for:

* Testing Kafka applications
* Debugging producers
* Viewing messages in a topic
* Learning Kafka fundamentals
* Verifying partition distribution

---

# Kafka Consumer Command

Depending on your operating system:

| Environment                  | Command                         |
| ---------------------------- | ------------------------------- |
| Linux / macOS                | `kafka-console-consumer.sh`     |
| Windows                      | `kafka-console-consumer.bat`    |
| PATH Configured              | `kafka-console-consumer`        |
| Kafka Home Not Added to PATH | `bin/kafka-console-consumer.sh` |

Verify installation:

```bash
kafka-console-consumer.sh
```

---

# Consumer Fundamentals

A consumer reads messages from Kafka topics.

```text
Producer
    |
    v
+-------------+
|   Topic     |
+-------------+
    |
    v
Consumer
```

Example:

```text
Orders Topic
├── Order 1
├── Order 2
└── Order 3

Consumer reads:
Order 1
Order 2
Order 3
```

---

# Using Conduktor Playground

## Step 1: Create a Topic

Create a topic with three partitions:

```bash
kafka-topics.sh \
--command-config playground.config \
--bootstrap-server cluster.playground.cdkt.io:9092 \
--topic second_topic \
--create \
--partitions 3
```

---

## Step 2: Start a Consumer

```bash
kafka-console-consumer.sh \
--consumer.config playground.config \
--bootstrap-server cluster.playground.cdkt.io:9092 \
--topic second_topic
```

The consumer now waits for incoming messages.

---

## Step 3: Produce Messages

Open another terminal:

```bash
kafka-console-producer.sh \
--producer.config playground.config \
--bootstrap-server cluster.playground.cdkt.io:9092 \
--producer-property partitioner.class=org.apache.kafka.clients.producer.RoundRobinPartitioner \
--topic second_topic
```

Send messages:

```text
Hello Kafka
Learning Kafka
Conduktor Rocks
```

Consumer output:

```text
Hello Kafka
Learning Kafka
Conduktor Rocks
```

---

# Round Robin Partitioner

The producer is configured with:

```bash
--producer-property partitioner.class=org.apache.kafka.clients.producer.RoundRobinPartitioner
```

Messages are distributed evenly across partitions.

Example:

```text
Message 1 -> Partition 0
Message 2 -> Partition 1
Message 3 -> Partition 2
Message 4 -> Partition 0
Message 5 -> Partition 1
```

Visualization:

```text
second_topic

Partition 0
 ├─ Message 1
 └─ Message 4

Partition 1
 ├─ Message 2
 └─ Message 5

Partition 2
 └─ Message 3
```

This helps balance workload across consumers.

---

# Consume Messages from the Beginning

Normally, consumers read only new messages.

To read all historical messages:

```bash
kafka-console-consumer.sh \
--consumer.config playground.config \
--bootstrap-server cluster.playground.cdkt.io:9092 \
--topic second_topic \
--from-beginning
```

Example:

```text
Message 1
Message 2
Message 3
Message 4
```

### Why Use `--from-beginning`?

Useful for:

* Data verification
* Replaying events
* Testing
* Debugging

---

# Display Metadata

Kafka stores more than just message values.

Messages contain:

```text
Timestamp
Key
Value
Partition
Offset
```

Display message metadata:

```bash
kafka-console-consumer.sh \
--consumer.config playground.config \
--bootstrap-server cluster.playground.cdkt.io:9092 \
--topic second_topic \
--formatter kafka.tools.DefaultMessageFormatter \
--property print.timestamp=true \
--property print.key=true \
--property print.value=true \
--property print.partition=true \
--from-beginning
```

Example output:

```text
CreateTime:1720100000    Partition:0    Key:name    Value:Stephane

CreateTime:1720100001    Partition:1    Key:null    Value:Hello Kafka
```

---

# Using Local Kafka

Default broker:

```text
localhost:9092
```

---

## Create Topic

```bash
kafka-topics.sh \
--bootstrap-server localhost:9092 \
--topic second_topic \
--create \
--partitions 3
```

---

## Start Consumer

```bash
kafka-console-consumer.sh \
--bootstrap-server localhost:9092 \
--topic second_topic
```

Consumer waits for messages.

---

## Start Producer

Open a second terminal:

```bash
kafka-console-producer.sh \
--bootstrap-server localhost:9092 \
--producer-property partitioner.class=org.apache.kafka.clients.producer.RoundRobinPartitioner \
--topic second_topic
```

Send:

```text
Kafka
Spark
Databricks
```

Consumer output:

```text
Kafka
Spark
Databricks
```

---

# Consume All Existing Messages

```bash
kafka-console-consumer.sh \
--bootstrap-server localhost:9092 \
--topic second_topic \
--from-beginning
```

Output:

```text
Kafka
Spark
Databricks
```

---

# Display Metadata

```bash
kafka-console-consumer.sh \
--bootstrap-server localhost:9092 \
--topic second_topic \
--formatter kafka.tools.DefaultMessageFormatter \
--property print.timestamp=true \
--property print.key=true \
--property print.value=true \
--property print.partition=true \
--from-beginning
```

Example:

```text
CreateTime:1720100000    Partition:0    Key:null    Value:Kafka

CreateTime:1720100001    Partition:1    Key:null    Value:Spark

CreateTime:1720100002    Partition:2    Key:null    Value:Databricks
```

---

# Understanding Consumer Offsets

Kafka tracks how much data a consumer has read.

Example:

```text
Partition 0

Offset 0 -> Kafka
Offset 1 -> Spark
Offset 2 -> Databricks
```

Consumer progress:

```text
Current Offset = 2
```

Meaning:

```text
Messages 0 and 1 consumed
Currently at message 2
```

---

# Consumer Workflow

```text
1. Create Topic
       |
       v
2. Produce Messages
       |
       v
3. Start Consumer
       |
       v
4. Read Messages
       |
       v
5. Commit Offsets
```

---

# Producer vs Consumer

| Producer         | Consumer          |
| ---------------- | ----------------- |
| Sends messages   | Reads messages    |
| Writes to topics | Reads from topics |
| Creates records  | Processes records |
| Uses partitions  | Reads partitions  |
| Controls keys    | Tracks offsets    |

---

# Common Consumer Commands

## Consume New Messages

```bash
kafka-console-consumer.sh \
--bootstrap-server localhost:9092 \
--topic my_topic
```

---

## Consume All Messages

```bash
kafka-console-consumer.sh \
--bootstrap-server localhost:9092 \
--topic my_topic \
--from-beginning
```

---

## Display Metadata

```bash
kafka-console-consumer.sh \
--bootstrap-server localhost:9092 \
--topic my_topic \
--formatter kafka.tools.DefaultMessageFormatter \
--property print.timestamp=true \
--property print.key=true \
--property print.value=true \
--property print.partition=true
```

---

# Best Practices

## Use Multiple Partitions

More partitions allow:

* Higher throughput
* Parallel processing
* Better scalability

---

## Use Keys When Ordering Matters

Example:

```text
customer_1001
customer_1001
customer_1001
```

All records remain in the same partition, preserving order.

---

## Use `--from-beginning` Carefully

For large topics:

```bash
--from-beginning
```

may read millions of messages.

Use it primarily for:

* Testing
* Troubleshooting
* Data validation

---

# Summary

The Kafka Console Consumer is the easiest way to read data from Kafka topics.

Key concepts covered:

* Consuming messages
* Reading from the beginning
* Viewing metadata
* Understanding partitions
* Understanding offsets
* Round Robin partitioning
* Consumer best practices

Together with the Kafka Console Producer, it forms the simplest end-to-end workflow for learning and testing Apache Kafka.
# Where Is the Consumer Code?

The command:

```bash
kafka-console-consumer.sh \
--bootstrap-server localhost:9092 \
--topic second_topic
```

is actually a ready-made Kafka consumer application provided by Apache Kafka.

When you run this command, Kafka starts a consumer process that:

1. Connects to the Kafka broker.
2. Subscribes to the specified topic.
3. Reads messages from the topic partitions.
4. Displays the messages on the terminal.
5. Tracks offsets to remember which messages have been consumed.

---

## Console Consumer vs Application Consumer

### Console Consumer

```bash
kafka-console-consumer.sh \
--bootstrap-server localhost:9092 \
--topic second_topic
```

Purpose:

* Testing Kafka
* Learning Kafka
* Debugging topics
* Viewing messages quickly

---

## Java Consumer Example

The console consumer performs operations similar to the following Java code:

```java
Properties props = new Properties();

props.put("bootstrap.servers", "localhost:9092");
props.put("group.id", "my-consumer-group");
props.put("key.deserializer",
          "org.apache.kafka.common.serialization.StringDeserializer");
props.put("value.deserializer",
          "org.apache.kafka.common.serialization.StringDeserializer");

KafkaConsumer<String, String> consumer =
        new KafkaConsumer<>(props);

consumer.subscribe(Arrays.asList("second_topic"));

while (true) {

    ConsumerRecords<String, String> records =
            consumer.poll(Duration.ofMillis(100));

    for (ConsumerRecord<String, String> record : records) {

        System.out.println(
                "Partition: " + record.partition()
                + ", Offset: " + record.offset()
                + ", Value: " + record.value()
        );
    }
}
```

---

## Python Consumer Example

Using the `kafka-python` library:

```python
from kafka import KafkaConsumer

consumer = KafkaConsumer(
    'second_topic',
    bootstrap_servers='localhost:9092',
    auto_offset_reset='earliest'
)

for message in consumer:
    print(
        f"Partition={message.partition}, "
        f"Offset={message.offset}, "
        f"Value={message.value.decode('utf-8')}"
    )
```

---

## What Happens Internally?

```text
Producer
   |
   v
+--------------+
| second_topic |
+--------------+
   |
   +--> Partition 0
   +--> Partition 1
   +--> Partition 2
           |
           v
       Consumer
```

The consumer continuously polls Kafka for new records and processes them as they arrive.

---

## Key Takeaway

The Kafka console consumer is simply a pre-built consumer application supplied by Apache Kafka. It allows you to consume messages immediately without writing Java, Python, Spring Boot, or Spark code. Once you understand the console consumer, the next step is building your own consumer applications using Kafka client libraries.
