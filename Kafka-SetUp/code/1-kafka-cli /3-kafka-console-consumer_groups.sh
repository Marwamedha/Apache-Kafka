# Kafka Consumer Groups Guide

## Overview

A **Consumer Group** is a collection of consumers working together to consume data from a topic.

Consumer groups provide:

* Scalability
* Load balancing
* Fault tolerance
* Parallel processing

Without consumer groups, every consumer would receive every message.

With consumer groups, Kafka distributes partitions among consumers.

---

# Why Consumer Groups?

Imagine a topic receiving millions of messages per day.

```text
Orders Topic
├── Partition 0
├── Partition 1
└── Partition 2
```

A single consumer may not process data fast enough.

Instead, Kafka allows multiple consumers to share the workload.

```text
Consumer Group A

Consumer 1
Consumer 2
Consumer 3
```

Each consumer processes a subset of partitions.

---

# Create a Topic

Create a topic with three partitions:

```bash
kafka-topics.sh \
--bootstrap-server localhost:9092 \
--topic third_topic \
--create \
--partitions 3
```

Verify:

```bash
kafka-topics.sh \
--bootstrap-server localhost:9092 \
--topic third_topic \
--describe
```

Expected:

```text
Topic: third_topic
PartitionCount: 3
```

---

# Start the First Consumer

```bash
kafka-console-consumer.sh \
--bootstrap-server localhost:9092 \
--topic third_topic \
--group my-first-application
```

This creates a consumer group:

```text
Group ID = my-first-application
```

Kafka automatically registers the consumer inside the group.

---

# Start a Producer

Open another terminal:

```bash
kafka-console-producer.sh \
--bootstrap-server localhost:9092 \
--producer-property partitioner.class=org.apache.kafka.clients.producer.RoundRobinPartitioner \
--topic third_topic
```

Send messages:

```text
Message 1
Message 2
Message 3
Message 4
Message 5
Message 6
```

Because the producer uses the Round Robin partitioner:

```text
Message 1 -> Partition 0
Message 2 -> Partition 1
Message 3 -> Partition 2
Message 4 -> Partition 0
Message 5 -> Partition 1
Message 6 -> Partition 2
```

---

# Add a Second Consumer to the Same Group

Open a third terminal:

```bash
kafka-console-consumer.sh \
--bootstrap-server localhost:9092 \
--topic third_topic \
--group my-first-application
```

Now Kafka detects a new consumer.

A rebalance occurs.

---

## Before Rebalance

```text
Group: my-first-application

Consumer 1
 ├── Partition 0
 ├── Partition 1
 └── Partition 2
```

---

## After Rebalance

```text
Group: my-first-application

Consumer 1
 ├── Partition 0
 └── Partition 2

Consumer 2
 └── Partition 1
```

Messages are now shared between consumers.

---

# Important Rule

Within the same consumer group:

```text
One Partition
      =
One Consumer
```

A partition can only be assigned to one consumer in a group at a time.

---

# More Consumers Than Partitions

Example:

```text
Topic Partitions = 3

Consumers = 4
```

Result:

```text
Consumer 1 -> Partition 0
Consumer 2 -> Partition 1
Consumer 3 -> Partition 2
Consumer 4 -> Idle
```

Kafka cannot assign more than one consumer to the same partition within a group.

---

# Create a Second Consumer Group

Start another consumer:

```bash
kafka-console-consumer.sh \
--bootstrap-server localhost:9092 \
--topic third_topic \
--group my-second-application \
--from-beginning
```

Notice the different group:

```text
my-second-application
```

This group is completely independent.

---

# Multiple Consumer Groups

```text
Topic: third_topic

Consumer Group A
 ├── Consumer A1
 └── Consumer A2

Consumer Group B
 └── Consumer B1
```

Each group receives its own copy of the data.

---

# Message Flow Example

```text
Producer
   |
   v
+--------------+
| third_topic  |
+--------------+
   |
   +--> Group A
   |      |
   |      +--> Consumer A1
   |      +--> Consumer A2
   |
   +--> Group B
          |
          +--> Consumer B1
```

Result:

* Group A receives all messages.
* Group B receives all messages.
* Within Group A, messages are shared.
* Within Group B, messages are shared among its members.

---

# Understanding Offsets by Group

Offsets are stored separately for each group.

Example:

```text
Topic

Offset 0
Offset 1
Offset 2
Offset 3
Offset 4
```

Group A:

```text
Current Offset = 4
```

Group B:

```text
Current Offset = 2
```

Kafka tracks progress independently.

---

# Why Use `--from-beginning`?

```bash
--from-beginning
```

When a new consumer group starts, it can read all historical messages.

Example:

```bash
kafka-console-consumer.sh \
--bootstrap-server localhost:9092 \
--topic third_topic \
--group analytics-team \
--from-beginning
```

Useful for:

* Analytics
* Auditing
* Reprocessing
* Data migration

---

# Real-World Example

Imagine an e-commerce platform.

```text
orders topic
```

Different teams need the same data.

### Inventory Service

```text
Group: inventory-service
```

Updates stock levels.

---

### Billing Service

```text
Group: billing-service
```

Processes payments.

---

### Analytics Service

```text
Group: analytics-service
```

Builds dashboards and reports.

---

All groups receive every order event independently.

---

# Consumer Group Rebalancing

A rebalance happens when:

* A consumer joins
* A consumer leaves
* A consumer crashes
* The number of partitions changes

Kafka redistributes partitions automatically.

---

# Consumer Group Best Practices

## Match Consumers to Partitions

Example:

```text
3 Partitions
3 Consumers
```

Optimal utilization.

---

## Avoid Excess Consumers

Example:

```text
3 Partitions
10 Consumers
```

Seven consumers remain idle.

---

## Use Meaningful Group Names

Good examples:

```text
inventory-service
billing-service
analytics-service
```

Avoid:

```text
group1
group2
test123
```

---

# Consumer Groups Summary

| Concept                 | Description                                |
| ----------------------- | ------------------------------------------ |
| Consumer Group          | A set of consumers working together        |
| Group ID                | Unique identifier of a consumer group      |
| Rebalance               | Redistribution of partitions               |
| Offset                  | Position of a consumer within a partition  |
| Partition Ownership     | One partition per consumer within a group  |
| Independent Consumption | Different groups receive the same messages |

---

# Key Takeaways

* Consumer groups enable Kafka scalability.
* Consumers within the same group share partitions.
* Different consumer groups receive the same data independently.
* Offsets are tracked per group.
* Kafka automatically rebalances partitions when consumers join or leave.
* The maximum useful number of consumers in a group equals the number of partitions.
