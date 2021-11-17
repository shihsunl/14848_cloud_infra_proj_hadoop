FROM ubuntu:18.04
ENV DEBIAN_FRONTEND noninteractive
MAINTAINER Shih-Sung-Lin
ENV PORT 8088
ENV DOCKER_HOSTNAME=hadoop-service
ENV HOSTNAME=hadoop-service

RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d
ENV JAVA_HOME=/usr/lib/jdk1.8.0_211
ENV HADOOP_HOME=/temp/hadoop/hadoop-3.3.1
ENV PATH=$PATH:$JAVA_HOME/bin:$HADOOP_HOME/bin
EXPOSE 8088 8080 8090 8020 8042 8033 8040 8044 8048 8188 8021 8190 8047 8788 8046 8045 8049 8089 8091 8485 8480 8481 8030 8031 8032 9000 9864  9865 9866 9868 9869 9870 10020 16010 16030 19888 19890 50070 50470 50075 50475 50090 50010 50020 50030 50060 51111 50200
# docker run -p 8088:8088 -p 8080:8080 -p 8090:8090 -p 8042:8042 -p 50070:50070 -p 50470:50470 -p 8020:8020 -p 9000:9000 -p 8033:8033 -p 8040:8040 -p 8048:8048 -p 8044:8044 -p 8188:8188 -p 8021:8021 -p 8190:8190 -p 8047:8047 -p 8788:8788 -p 8046:8046 -p 8045:8045 -p 8049:8049 -p 8089:8089 -p 8091:8091 -p 8030:8030 -p 8031:8031 -p 8032:8032 -p 50071:50070 -p 50075:50075 -p 50010:50010 -p 50020:50020 -p 50100:50100 -p 50060:50060 -p 50030:50030 -p 50090:50090 -p 9870:9870 -p 9864:9864 -p 9868:9868 -p 16010:16010 -p 16030:16030 --rm -it shihsunl/14848_proj_hadoop

# setup
RUN apt-get update
RUN apt-get install -y git g++ software-properties-common build-essential language-pack-en unzip curl wget vim libpam0g-dev libssl-dev cmake cron libssl-dev openssl iputils-ping openssh-server sudo openssh-client
#RUN apt-get install -y python3
#RUN add-apt-repository ppa:deadsnakes/ppa -y
#RUN apt-get install -y python3-pip
#RUN pip3 install Flask==2.0.1
#RUN pip3 install gunicorn==20.1.0

# install jdk
RUN mkdir /temp
RUN mkdir /temp/install
WORKDIR /temp/install
RUN wget https://github.com/frekele/oracle-java/releases/download/8u211-b12/jdk-8u211-linux-x64.tar.gz
RUN tar -zxvf jdk-8u211-linux-x64.tar.gz
RUN cp -R /temp/install/jdk1.8.0_211 /usr/lib/jdk1.8.0_211
RUN ln -s /usr/lib/jdk1.8.0_211/bin/java /etc/alternatives/java

# ssh for debugging
RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u 1000 test
RUN echo 'test:test' | chpasswd # sets the password for the user test to test

# generate a ssh key
RUN ssh-keygen -q -t rsa -N '' -f /root/.ssh/id_rsa &&\
    cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

# install hadoop
RUN mkdir /temp/hadoop
WORKDIR /temp/hadoop
RUN curl -L https://dlcdn.apache.org/hadoop/common/hadoop-3.3.1/hadoop-3.3.1.tar.gz -o hadoop-3.3.1.tar.gz
RUN tar -zxvf hadoop-3.3.1.tar.gz

# set up config
RUN echo "export HDFS_NAMENODE_USER=root" >> /temp/hadoop/hadoop-3.3.1/etc/hadoop/hadoop-env.sh
RUN echo "export HDFS_DATANODE_USER=root" >> /temp/hadoop/hadoop-3.3.1/etc/hadoop/hadoop-env.sh
RUN echo "export HDFS_SECONDARYNAMENODE_USER=root" >> /temp/hadoop/hadoop-3.3.1/etc/hadoop/hadoop-env.sh
RUN echo "export YARN_RESOURCEMANAGER_USER=root" >> /temp/hadoop/hadoop-3.3.1/etc/hadoop/hadoop-env.sh
RUN echo "export YARN_NODEMANAGER_USER=root" >> /temp/hadoop/hadoop-3.3.1/etc/hadoop/hadoop-env.sh
RUN echo "export JAVA_HOME=/usr/lib/jdk1.8.0_211" >> /temp/hadoop/hadoop-3.3.1/etc/hadoop/hadoop-env.sh
RUN echo "export APPLICATION_WEB_PROXY_BASE=hadoop/" >> /temp/hadoop/hadoop-3.3.1/etc/hadoop/hadoop-env.sh
RUN echo "export CORE_CONF_fs_defaultFS=hdfs://localhost:9000" >> /temp/hadoop/hadoop-3.3.1/etc/hadoop/hadoop-env.sh
RUN echo "export HDFS_CONF_dfs_namenode_name_dir=file:///tmp/hadoop-root/dfs/name" >> /temp/hadoop/hadoop-3.3.1/etc/hadoop/hadoop-env.sh
RUN echo "export HDFS_CONF_dfs_webhdfs_enabled=true" >> /temp/hadoop/hadoop-3.3.1/etc/hadoop/hadoop-env.sh
RUN echo "export HDFS_CONF_dfs_permissions_enabled=false" >> /temp/hadoop/hadoop-3.3.1/etc/hadoop/hadoop-env.sh
RUN echo "export HDFS_CONF_dfs_namenode_datanode_registration_ip___hostname___check=false" >> /temp/hadoop/hadoop-3.3.1/etc/hadoop/hadoop-env.sh

# Setup configuration
RUN sed -i '/^<configuration>.*/a <property><name>fs.defaultFS</name><value>hdfs://localhost:9000</value></property><property><name>dfs.replication</name><value>2</value></property>' /temp/hadoop/hadoop-3.3.1/etc/hadoop/core-site.xml
#cp temp/hadoop/hadoop-3.3.1/etc/hadoop/new_core-site.xml /temp/hadoop/hadoop-3.3.1/etc/hadoop/core-site.xml

RUN sed -i '/^<configuration>.*/a <property><name>dfs.namenode.name.dir</name><value>/tmp/hadoop-root/dfs/data/nameNode</value></property><property><name>dfs.datanode.data.dir</name><value>/tmp/hadoop-root/dfs/data/dataNode</value></property><property><name>dfs.replication</name><value>2</value></property>' /temp/hadoop/hadoop-3.3.1/etc/hadoop/hdfs-site.xml
#cp temp/hadoop/hadoop-3.3.1/etc/hadoop/new_hdfs-site.xml /temp/hadoop/hadoop-3.3.1/etc/hadoop/hdfs-site.xml

RUN /etc/init.d/ssh restart && /temp/hadoop/hadoop-3.3.1/sbin/start-all.sh

RUN mkdir -p /tmp/hadoop-root/dfs/data/dataNode &&\
    mkdir -p /tmp/hadoop-root/dfs/data/nameNode &&\
    chmod -R 755 /tmp/hadoop-root/dfs/data/

ENV HDFS_CONF_dfs_namenode_name_dir=file:///tmp/hadoop-root/dfs/name
RUN hdfs namenode -format

# Fix yarn logo
WORKDIR /temp
RUN git clone https://github.com/shihsunl/14848_cloud_infra_proj_hadoop.git
RUN cp -r /temp/14848_cloud_infra_proj_hadoop/* /temp/
# fix issue for showing a image when using reverse proxy base url
RUN cp -r /temp/hadoop_fix/hadoop-yarn-common-3.3.1.jar /temp/hadoop/hadoop-3.3.1/share/hadoop/yarn/

# web terminal
WORKDIR /temp
RUN wget https://github.com/yudai/gotty/releases/download/v2.0.0-alpha.3/gotty_2.0.0-alpha.3_linux_amd64.tar.gz &&\
    tar -zxvf gotty_2.0.0-alpha.3_linux_amd64.tar.gz &&\
    echo "/temp/gotty -a 0.0.0.0 --ws-origin '.*' -w bash > /temp/gotty.out >2&1 &" > /temp/gotty.sh && chmod 777 /temp/*

WORKDIR /temp
CMD /etc/init.d/ssh restart && /temp/hadoop/hadoop-3.3.1/sbin/start-all.sh && /temp/gotty -a 0.0.0.0 --ws-origin ".*" -w bash
