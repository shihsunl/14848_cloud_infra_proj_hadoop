FROM ubuntu:18.04
ENV DEBIAN_FRONTEND noninteractive
MAINTAINER Shih-Sung-Lin
ENV PORT 8088

RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d
ENV JAVA_HOME=/usr/lib/jdk1.8.0_211
ENV PATH=$PATH:$JAVA_HOME/bin
EXPOSE 8088 8080

# setup
RUN apt-get update
RUN apt-get install -y git g++ software-properties-common build-essential language-pack-en unzip curl wget vim libpam0g-dev libssl-dev cmake cron libssl-dev openssl iputils-ping openssh-server sudo
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

# install hadoop
RUN mkdir /temp/hadoop
WORKDIR /temp/hadoop
RUN curl -L https://dlcdn.apache.org/hadoop/common/hadoop-3.3.1/hadoop-3.3.1.tar.gz -o hadoop-3.3.1.tar.gz
RUN tar -zxvf hadoop-3.3.1.tar.gz
ENV HADOOP_HOME=/temp/hadoop/hadoop-3.3.1

# set up config
RUN echo "export HDFS_NAMENODE_USER=root" >> /temp/hadoop/hadoop-3.3.1/etc/hadoop/hadoop-env.sh
RUN echo "export HDFS_DATANODE_USER=root" >> /temp/hadoop/hadoop-3.3.1/etc/hadoop/hadoop-env.sh
RUN echo "export HDFS_SECONDARYNAMENODE_USER=root" >> /temp/hadoop/hadoop-3.3.1/etc/hadoop/hadoop-env.sh
RUN echo "export YARN_RESOURCEMANAGER_USER=root" >> /temp/hadoop/hadoop-3.3.1/etc/hadoop/hadoop-env.sh
RUN echo "export YARN_NODEMANAGER_USER=root" >> /temp/hadoop/hadoop-3.3.1/etc/hadoop/hadoop-env.sh
RUN echo "export JAVA_HOME=/usr/lib/jdk1.8.0_211" >> /temp/hadoop/hadoop-3.3.1/etc/hadoop/hadoop-env.sh
RUN echo "export APPLICATION_WEB_PROXY_BASE=hadoop/" >> /temp/hadoop/hadoop-3.3.1/etc/hadoop/hadoop-env.sh
#RUN echo "sleep infinity" >> /temp/hadoop/hadoop-3.3.1/sbin/start-all.sh

WORKDIR /temp
RUN git clone https://github.com/shihsunl/14848_cloud_infra_proj_hadoop.git
RUN cp -r /temp/14848_cloud_infra_proj_hadoop/* /temp/
# fix issue for showing a image when using reverse proxy base url
RUN cp -r /temp/hadoop_fix/hadoop-yarn-common-3.3.1.jar /temp/hadoop/hadoop-3.3.1/share/hadoop/yarn/

# ssh for debugging
RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u 1000 test
RUN echo 'test:test' | chpasswd # sets the password for the user test to test

# web terminal
WORKDIR /temp
RUN wget https://github.com/yudai/gotty/releases/download/v2.0.0-alpha.3/gotty_2.0.0-alpha.3_linux_amd64.tar.gz &&\
    tar -zxvf gotty_2.0.0-alpha.3_linux_amd64.tar.gz &&\
    echo "/temp/gotty -a 0.0.0.0 --ws-origin '.*' -w bash > /temp/gotty.out >2&1 &" > /temp/gotty.sh && chmod 777 /temp/*

WORKDIR /temp
CMD /temp/hadoop/hadoop-3.3.1/sbin/start-all.sh && /temp/gotty -a 0.0.0.0 --ws-origin ".*" -w bash
