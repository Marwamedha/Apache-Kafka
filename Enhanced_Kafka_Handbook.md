# Enhanced Apache Kafka Handbook

## Overview
This enhanced version expands the original notes with:
- Practical explanations
- Real-world examples
- Interview questions
- Best practices
- Architecture diagrams
- Troubleshooting tips

---

# Kafka Fundamentals

Apache Kafka is a distributed event-streaming platform used for building real-time data pipelines and streaming applications.

## Core Components

| Component | Description |
|------------|------------|
| Producer | Sends messages |
| Topic | Logical stream of data |
| Partition | Unit of parallelism |
| Broker | Kafka server |
| Consumer | Reads messages |
| Consumer Group | Scales consumption |
| Offset | Position of a record |

---

# Why Kafka?

- High throughput
- Horizontal scalability
- Fault tolerance
- Durability
- Real-time processing

Example use cases:
- Telecom event processing
- Fraud detection
- Clickstream analytics
- IoT telemetry
- CDC pipelines

---

# Topic Design Best Practices

1. Use meaningful topic names.
2. Plan partitions based on throughput.
3. Avoid excessive partitions.
4. Define retention according to business needs.
5. Use schema governance.

Example:

customer-events
payment-transactions
network-alarms

---

# Partitions and Ordering

Ordering is guaranteed only within a partition.

Example:

Customer 101:
- Order Created
- Order Updated
- Order Delivered

Using CustomerID as the key ensures all events stay ordered.

---

# Producer Best Practices

- Enable retries
- Use idempotent producers
- Choose proper acknowledgements
- Monitor latency

Recommended:

acks=all

For critical workloads.

---

# Consumer Best Practices

- Commit offsets after processing
- Implement retry logic
- Handle duplicates
- Monitor lag

---

# Delivery Semantics Comparison

| Type | Duplicates | Data Loss |
|--------|------------|------------|
| At Most Once | No | Possible |
| At Least Once | Possible | No |
| Exactly Once | No | No |

---

# Real-World Telecom Example

Network Events
→ Kafka
→ Spark Streaming
→ Data Warehouse
→ Power BI Dashboard

Benefits:
- Real-time insights
- Fault tolerance
- Scalability

---

# Common Interview Questions

### What is a Kafka partition?

A partition is the scalability and ordering unit of a topic.

### What is an offset?

The unique position of a record within a partition.

### Why use a message key?

To guarantee ordering for related events.

### What happens when a consumer crashes?

Kafka resumes from the last committed offset.

---

# Troubleshooting

## High Consumer Lag

Possible reasons:
- Slow processing
- Insufficient consumers
- Network bottlenecks

## Uneven Partition Distribution

Possible reasons:
- Poor key selection
- Skewed data

---

# ZooKeeper vs KRaft

| ZooKeeper | KRaft |
|------------|------------|
| Separate cluster | Built into Kafka |
| More operational overhead | Simpler |
| Legacy architecture | Modern architecture |

---

# Quick Revision

✅ Topic = stream of events

✅ Partition = scalability

✅ Offset = message position

✅ Producer = write

✅ Consumer = read

✅ Broker = Kafka server

✅ Replication = fault tolerance

✅ KRaft = ZooKeeper replacement
