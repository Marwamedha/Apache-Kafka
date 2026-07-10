# Kafka Theory - Reimagined Notes

> Same concepts, same flow, same images — rewritten with clearer explanations and study-friendly wording.

# Kafka Topics

- A **Topic** is Kafka's way of organizing streams of events.
- Think of it as a category where related messages are continuously stored.
- Similar to a database table, but Kafka does not enforce a fixed schema.
- Every topic has a unique name.
- Multiple producers can write to the same topic.
- Multiple consumers can read from the same topic.
- The ordered collection of events inside a topic forms a **data stream**.

![1746259704767](images/Kafkatheory/1746259704767.png)

## Partitions and Offsets

Topics are divided into **Partitions** to improve scalability and throughput.

- Messages inside a partition are stored in sequence.
- Every message receives a unique incremental identifier called an **Offset**.

![1746260352353](images/Kafkatheory/1746260352353.png)

> Once a record is written, it cannot be modified.

> Kafka keeps records only for the configured retention period.

> Offsets are meaningful only within their partition.

> Deleted messages do not cause offset reuse.

> Ordering is guaranteed only inside a single partition.

> Without a key, Kafka distributes records automatically.

> Topics can contain many partitions depending on scale requirements.

# Producers

- Producers are applications that publish data to Kafka topics.
- Kafka producers follow a push model.
- Producers know which broker and partition will receive a record.
- They can recover automatically from many broker failures.

![1746261948193](images/Kafkatheory/1746261948193.png)

### Message Keys

A producer can optionally attach a key to a message.

- The key influences partition selection.
- Messages with the same key are routed to the same partition.

> key = null → records are distributed across partitions.

> key != null → records are hashed and routed consistently.

![1746263166047](images/Kafkatheory/1746263166047.png)

### Kafka Message Anatomy

A Kafka record contains metadata and a value.

- Key → optional routing identifier
- Value → actual business data
- Timestamp → creation time
- Headers → optional metadata

![1746263509065](images/Kafkatheory/1746263509065.png)

### Kafka Message Serialization

Kafka stores only bytes.

Before sending data:

Application Object → Serializer → Bytes → Kafka

Common serialization formats:

1. JSON
2. String
3. Integer / Float
4. Avro
5. Protobuf

![1746264316815](images/Kafkatheory/1746264316815.png)

### Key Hashing

Kafka uses a partitioner to determine where a message should go.

partition = murmur2(key) % num_partitions

# Consumers

- Consumers read records from Kafka topics.
- Kafka uses a pull model.
- Consumers automatically discover the correct brokers.
- They can resume reading after failures.
- Records are read in offset order within a partition.

![1746266239858](images/Kafkatheory/1746266239858.png)

### Consumer Deserialization

Consumers convert Kafka bytes back into usable data.

![1746266902740](images/Kafkatheory/1746266902740.png)

Important:

- Producers and consumers must agree on the same format.
- Changing JSON to Avro without updating consumers will break processing.
- Kafka stores bytes and does not validate payload formats.

# Consumer Groups

A consumer group is a set of consumers sharing the workload.

- Kafka ensures a partition is consumed by only one consumer within a group.
- Consumer groups provide scalability and fault tolerance.

![1746282962083](images/Kafkatheory/1746282962083.png)

### Why Consumer Groups?

Without groups:

- Consumer A reads everything.
- Consumer B reads everything.
- Consumer C reads everything.

With groups:

- Workload is split across consumers.

### Too Many Consumers

If consumers exceed partitions, some consumers stay idle.

![1746283067571](images/Kafkatheory/1746283067571.png)

### Multiple Consumer Groups

Different applications can consume the same topic independently.

![1746283184408](images/Kafkatheory/1746283184408.png)

### Consumer Offsets

Kafka tracks progress using committed offsets stored in:

__consumer_offsets

Offset = current reading position.

Committed Offset = saved checkpoint.

If a consumer restarts, Kafka resumes from the last committed position.

### Delivery Semantics

#### At Least Once

- Read
- Process
- Commit

Pros:
- No data loss

Cons:
- Duplicate processing possible

#### At Most Once

- Read
- Commit
- Process

Pros:
- No duplicates

Cons:
- Possible message loss

#### Exactly Once

- No duplicates
- No message loss

Typically used for financial and critical systems.

# Brokers

A Kafka cluster consists of multiple brokers.

- Brokers store partitions.
- Brokers serve producers and consumers.
- Data is distributed across brokers.

![1746355411870](images/Kafkatheory1/1746355411870.png)

### Broker Discovery

Any broker can act as a bootstrap server.

![1746355738747](images/Kafkatheory1/1746355738747.png)

After connecting to one broker, Kafka provides metadata for the entire cluster.

# Topic Replication Factor

Replication provides fault tolerance.

![1746356491750](images/Kafkatheory1/1746356491750.png)

With replication factor 2, one broker failure can be tolerated.

![1746356597819](images/Kafkatheory1/1746356597819.png)

### Leaders and ISR

Each partition contains:

- One Leader
- One or more In-Sync Replicas (ISR)

![1746356904047](images/Kafkatheory1/1746356904047.png)

Producers write to leaders.

Replicas synchronize data from leaders.

Consumers normally read from leaders.

![1746357515155](images/Kafkatheory1/1746357515155.png)

### Replica Fetching

Kafka 2.4+ allows consumers to read from nearby replicas to reduce latency.

### Producer Acknowledgements

acks=0 → fastest, possible data loss

acks=1 → leader confirmation only

acks=all → leader and replicas confirm, highest durability

### Durability

For a replication factor N:

Kafka can typically tolerate up to N-1 broker failures without losing committed data.

# ZooKeeper and KRaft

ZooKeeper historically handled:

- Broker coordination
- Metadata management
- Leader election
- Cluster notifications

![1746358942427](images/Kafkatheory1/1746358942427.png)

### KRaft

KRaft removes the dependency on ZooKeeper.

Instead of a separate ZooKeeper cluster:

- Kafka manages metadata internally.
- A quorum controller coordinates the cluster.

![1746359204483](images/Kafkatheory1/1746359204483.png)

![1746359323674](images/Kafkatheory1/1746359323674.png)

![1746359344069](images/Kafkatheory1/1746359344069.png)

### Benefits of KRaft

- Simpler architecture
- Easier maintenance
- Better scalability
- Fewer moving parts
