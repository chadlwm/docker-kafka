FROM java:openjdk-8-jre
MAINTAINER liuwenmin "liuwenmin@sensetime.com"

# copy install package files from localhost.
ADD ./kafka_2.11-0.9.0.1.tgz /opt/

# Create kafka and log directories
RUN mkdir -p /opt/kafka_cluster/log && \
    mkdir -p /opt/kafka_cluster/conf && \
    mv /opt/kafka_2.11-0.9.0.1 /opt/kafka_cluster/kafka

RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak && \
    echo "deb http://mirrors.163.com/ubuntu/ trusty main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb http://mirrors.163.com/ubuntu/ trusty-security main restricted universe multiverse " >> /etc/apt/sources.list && \
    echo "deb http://mirrors.163.com/ubuntu/ trusty-updates main restricted universe multiverse " >> /etc/apt/sources.list && \
    echo "deb http://mirrors.163.com/ubuntu/ trusty-proposed main restricted universe multiverse " >> /etc/apt/sources.list && \
    echo "deb http://mirrors.163.com/ubuntu/ trusty-backports main restricted universe multiverse " >> /etc/apt/sources.list && \
    echo "deb-src http://mirrors.163.com/ubuntu/ trusty main restricted universe multiverse " >> /etc/apt/sources.list && \
    echo "deb-src http://mirrors.163.com/ubuntu/ trusty-security main restricted universe multiverse " >> /etc/apt/sources.list && \
    echo "deb-src http://mirrors.163.com/ubuntu/ trusty-updates main restricted universe multiverse " >> /etc/apt/sources.list && \
    echo "deb-src http://mirrors.163.com/ubuntu/ trusty-proposed main restricted universe multiverse " >> /etc/apt/sources.list && \
    echo "deb-src http://mirrors.163.com/ubuntu/ trusty-backports main restricted universe multiverse " >> /etc/apt/sources.list && \
    apt-get update

# install necessary tools
RUN apt-get install -y --force-yes wget supervisor dnsutils vim tmux lsof net-tools telnet
RUN rm -rf /var/lib/apt/lists/*
RUN apt-get clean

ADD supervisord.conf /etc/supervisor/conf.d/

# 2181 is zookeeper, 9092 is kafka
EXPOSE 2181 9092

# 2888 & 3888 is kafka internal connect port, not necessary to expose, recommand to user docker inner domain to connect within cluster.
# but if you set the clustor connecting with host ip, following ports should be exposed
# EXPOSE 2888 3888

# CMD "/data/scripts/kafka-start.sh"
# CMD "/bin/bash"
CMD ["supervisord", "-n"]
