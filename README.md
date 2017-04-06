# docker for kafka and zookeeper

## kafka version

kafka_2.11-0.9.0.1

## 设计思路

将外部盘挂在到 `docker` 的 `/data` 目录下，里面含有运行需要的文件夹和配置文件。

data目录下的文件夹和文件作用

- conf kafka和zookeeper配置文件目录
  - server.properties　kafkaf服务配置
  - zookeeper.properties zookeeper服务配置
- kafka-logs kafka文件存储目录
- logs kafka和zookeeper运行日志目录
- zookeeper zookeeper文件存储目录
  - myid zookeeper服务标识文件

docker 内部通过 supervisor 来启动zookeeper & kafka服务

## docker build

```
sudo docker build --rm -t chadliu/kafka:v2-files .
```

## single node 启动

```
sudo docker run -d -p 2181:2181 -p 9092:9092 -v /data/kafka/lc-docker/kafka-dir/:/data/ --name lc-kafka-1 -it 4ad06a59e8ff
```

## multi node and multi brokers 启动

注意几点：

- 如果docker内部访问kafka集群，则无需expose 端口出来, 直接用 container name访问即可
- 如果需要外部访问docker集群, 我们则需要对外提供一组broker list的ip:port, 要确保ip:port对外不变或者用zookeeper做动态服务发现，这里我们将container的端口expose到host的固定端口，用host_ip+port访问kafka集群，每个host上启动一个container, 不在同一个host上启动多个container, 如果只是测试，可以忽略这条。

### 修改配置文件

#### host 1

- zookeeper 配置文件 `conf/zookeeper.properties`

```
dataDir=/data/zookeeper
clientPort=2181
maxClientCnxns=0

initLimit=5
syncLimit=2

server.0=lc-kafka-1:2888:3888
server.1=lc-kafka-2:2888:3888
server.2=lc-kafka-3:2888:3888
```

- 标识文件　`zookeeper/myid`

```
0
```

- kafka 配置文件 `conf/server.properties`

```
broker.id=0
listeners=PLAINTEXT://:9092
host.name=lc-kafka-1
advertised.host.name=lc-kafka-1
log.dirs=/data/kafka-logs
num.partitions=15
log.retention.hours=168
zookeeper.connect=lc-kafka-1:2181,lc-kafka-2:2181,lc-kafka-3:2181
zookeeper.connection.timeout.ms=6000
default.replication.factor=2
```

#### host 2

- zookeeper配置文件 `conf/zookeeper.properties`

```
dataDir=/data/zookeeper
clientPort=2181
maxClientCnxns=0

initLimit=5
syncLimit=2

server.0=lc-kafka-1:2888:3888
server.1=lc-kafka-2:2888:3888
server.2=lc-kafka-3:2888:3888
```

- 标识文件　`zookeeper/myid`

```
1
```

- kafka 配置文件 `conf/server.properties`

```
broker.id=2
listeners=PLAINTEXT://:9092
host.name=lc-kafka-2
advertised.host.name=lc-kafka-2
log.dirs=/data/kafka-logs
num.partitions=15
log.retention.hours=168
zookeeper.connect=lc-kafka-1:2181,lc-kafka-2:2181,lc-kafka-3:2181
zookeeper.connection.timeout.ms=6000
default.replication.factor=2
```

#### host 3

- zookeeper配置文件 `conf/zookeeper.properties`

```
dataDir=/data/zookeeper
clientPort=2181
maxClientCnxns=0

initLimit=5
syncLimit=2

server.0=lc-kafka-1:2888:3888
server.1=lc-kafka-2:2888:3888
server.2=lc-kafka-3:2888:3888
```

- 标识文件　`zookeeper/myid`

```
2
```

- kafka 配置文件 `conf/server.properties`

```
broker.id=2
listeners=PLAINTEXT://:9092
host.name=lc-kafka-3
advertised.host.name=lc-kafka-3
log.dirs=/data/kafka-logs
num.partitions=15
log.retention.hours=168
zookeeper.connect=lc-kafka-1:2181,lc-kafka-2:2181,lc-kafka-3:2181
zookeeper.connection.timeout.ms=6000
default.replication.factor=2
```


### 启动

- host 1
```
sudo docker run -d -p 2181:2181 -p 9092:9092 -v /data/kafka/lc-docker/kafka-dir/:/data/ --name lc-kafka-1 -it 4ad06a59e8ff
```
- host 2
```
sudo docker run -d -p 2181:2181 -p 9092:9092 -v /data/kafka/lc-docker/kafka-dir/:/data/ --name lc-kafka-2 -it 4ad06a59e8ff
```
- host 3
```
sudo docker run -d -p 2181:2181 -p 9092:9092 -v /data/kafka/lc-docker/kafka-dir/:/data/ --name lc-kafka-3 -it 4ad06a59e8ff
```
###

## docker hub image地址

https://hub.docker.com/r/chadliu/kafka/
