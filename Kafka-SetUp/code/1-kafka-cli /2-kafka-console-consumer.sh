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
