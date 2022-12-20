# Apache Kafka

## Build
Via GitHub repository
```bash
$ docker build --tag alireaza/kafka:$(date -u +%Y%m%d) --tag alireaza/kafka:latest https://github.com/alireaza/kafka.git
```

## Run
```bash
$ docker run \
--interactive \
--tty \
--rm \
--publish="9092:9092" \
--name="kafka" \
alireaza/kafka
```

