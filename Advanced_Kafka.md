
# Apache Kafka - Complete Data Engineer Handbook

> Comprehensive Kafka notes with architecture figures, production concepts, interview preparation, and real-world examples.

---

# Kafka Architecture

```text
+------------+
| Producer A |
+------------+
       |
       v
+----------------------+
|      Kafka Topic     |
|  Partition 0         |
|  Partition 1         |
|  Partition 2         |
+----------------------+
       |
       v
+----------------------+
|   Consumer Group     |
+----------------------+
```

---

# What is Kafka?

Apache Kafka is a distributed event-streaming platform used to:

- Process real-time data
- Build event-driven systems
- Move data between applications
- Feed Data Lakes and Data Warehouses
- Support streaming analytics

Common users:

- Netflix
- Uber
- LinkedIn
- Airbnb
- Telecom Operators
- Banks

---

# End-to-End Data Flow

```text
Applications
      |
      v
Producers
      |
      v
Kafka Topics
      |
      v
Consumers
      |
      +------------+
      |            |
      v            v
 Data Lake    Real-Time Analytics
```

---

# Topics

A topic is a logical stream of events.

Examples:

- orders
- payments
- customer_updates
- telecom_events

Best Practices:

- Use lowercase names
- Avoid spaces
- Group by business domain
- Version schemas carefully

---

# Partitions

Partitions provide scalability.

Example:

```text
Orders Topic

Partition 0
Offset: 0 1 2 3

Partition 1
Offset: 0 1 2 3

Partition 2
Offset: 0 1 2 3
```

Important:

- Ordering exists only inside a partition
- Partitions enable parallel processing
- More partitions = more throughput

---

# Offsets

Offset = unique message position inside a partition.

```text
Partition 0

Offset 0 -> Order Created
Offset 1 -> Order Updated
Offset 2 -> Order Shipped
```

Offsets are:

- Sequential
- Immutable
- Never reused

---

# Producers

Producer responsibilities:

- Serialize data
- Select partition
- Retry failed writes
- Receive acknowledgements

Architecture:

```text
Application
     |
     v
Producer
     |
     v
Kafka Broker
```

---

# Message Keys

Without key:

```text
Message -> Random Partition
```

With key:

```text
CustomerID=123

Hash(CustomerID)
      |
      v
Partition 1
```

Benefits:

- Ordering guarantee
- Easier tracking
- Consistent routing

---

# Serialization

Kafka stores bytes only.

```text
JSON Object
      |
Serializer
      |
      v
Binary Data
      |
      v
Kafka
```

Popular formats:

| Format | Advantages |
|----------|----------|
| JSON | Human readable |
| Avro | Compact + Schema Evolution |
| Protobuf | High performance |
| String | Simple |
| Integer | Lightweight |

---

# Consumers

Consumers read messages.

Kafka uses Pull Model:

```text
Consumer ---> Kafka
          Request Data
```

Benefits:

- Consumer controls speed
- Better scalability
- Supports backpressure

---

# Consumer Groups

```text
Topic Partitions

P0 --> Consumer 1
P1 --> Consumer 2
P2 --> Consumer 3
```

Rules:

- One partition belongs to one consumer in the same group
- Multiple groups can read the same topic

---

# Consumer Rebalancing

Occurs when:

- Consumer joins
- Consumer leaves
- Partitions change

Figure:

```text
Before

C1 -> P0
C2 -> P1

After New Consumer

C1 -> P0
C2 -> P1
C3 -> P2
```

---

# Delivery Guarantees

## At Most Once

```text
Read
Commit
Process
```

Risk: Data loss

---

## At Least Once

```text
Read
Process
Commit
```

Risk: Duplicates

Most common strategy.

---

## Exactly Once

Uses:

- Transactions
- Idempotent Producers

Suitable for:

- Banking
- Payments
- Financial Systems

---

# Kafka Brokers

```text
Kafka Cluster

Broker 1
Broker 2
Broker 3
```

Responsibilities:

- Store partitions
- Serve producers
- Serve consumers
- Replicate data

---

# Replication

Replication Factor = 3

```text
Leader Broker

   |
   +--> Replica 1
   |
   +--> Replica 2
```

Benefits:

- Fault tolerance
- Durability
- High availability

---

# ISR (In-Sync Replicas)

```text
Leader
  |
  +--> ISR 1
  +--> ISR 2
```

ISR replicas stay synchronized with the leader.

---

# Producer Acknowledgements

| Setting | Durability | Speed |
|-----------|-----------|--------|
| acks=0 | Low | Fastest |
| acks=1 | Medium | Fast |
| acks=all | Highest | Slowest |

Recommended:

```text
acks=all
```

for production systems.

---

# Kafka Retention

Kafka stores data even after consumers read it.

Examples:

- 7 days
- 30 days
- 90 days

Benefits:

- Replay events
- Recovery
- Auditing

---

# Log Compaction

Instead of keeping all versions:

```text
Customer 1 -> A
Customer 1 -> B
Customer 1 -> C
```

Kafka keeps:

```text
Customer 1 -> C
```

Useful for:

- Reference data
- Latest state storage

---

# Kafka Connect

Kafka Connect moves data without coding.

Examples:

```text
Database --> Kafka
Kafka --> Snowflake
Kafka --> S3
Kafka --> Elasticsearch
```

Popular Connectors:

- JDBC
- S3
- Elasticsearch
- MongoDB

---

# Schema Registry

Used with:

- Avro
- Protobuf

Benefits:

- Version control
- Compatibility validation
- Governance

---

# Kafka Streams

Library for stream processing.

Example:

```text
Input Topic
      |
Kafka Streams
      |
Output Topic
```

Operations:

- Filter
- Join
- Aggregate
- Windowing

---

# Monitoring Metrics

Important KPIs:

- Consumer Lag
- Throughput
- Broker CPU
- Broker Memory
- Request Latency

Tools:

- Prometheus
- Grafana
- Confluent Control Center

---

# Common Production Issues

## High Consumer Lag

Causes:

- Slow processing
- Insufficient consumers
- Network issues

## Uneven Partition Load

Causes:

- Poor key selection
- Data skew

## Broker Storage Full

Solutions:

- Increase retention cleanup
- Add brokers
- Expand storage

---

# Telecom Real-Time Pipeline

```text
Network Events
      |
      v
Kafka
      |
      v
NiFi / StreamSets
      |
      v
Spark Streaming
      |
      v
Data Warehouse
      |
      v
Power BI
```

Use Cases:

- Anti-patching detection
- Fraud monitoring
- Network quality monitoring

---

# Interview Questions

### Why use Kafka instead of RabbitMQ?

Kafka focuses on high-throughput event streaming and replayability.

### What is Consumer Lag?

Difference between latest offset and consumed offset.

### Why use partitions?

Scalability and parallel processing.

### What is ISR?

Replicas fully synchronized with the leader.

### What happens when a broker fails?

A replica becomes the new leader.

### What is Log Compaction?

Retention strategy that keeps only the latest value per key.

---

# Quick Revision Sheet

✅ Topic = Event Stream

✅ Partition = Scalability Unit

✅ Offset = Record Position

✅ Producer = Writes Data

✅ Consumer = Reads Data

✅ Broker = Kafka Server

✅ Consumer Group = Parallel Consumption

✅ Replication = Fault Tolerance

✅ ISR = Synchronized Replicas

✅ Kafka Connect = Data Integration

✅ Schema Registry = Schema Governance

✅ Kafka Streams = Stream Processing

✅ KRaft = ZooKeeper Replacement
