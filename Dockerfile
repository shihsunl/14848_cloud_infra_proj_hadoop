FROM ubuntu:18.04
ENV DEBIAN_FRONTEND noninteractive
MAINTAINER Shih-Sung-Lin
ENV PORT 8088

RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d
ENV JAVA_HOME=/usr/lib/jdk1.8.0_211
ENV PATH=$PATH:$JAVA_HOME/bin
EXPOSE 8088

# setup
RUN apt-get update
RUN apt-get install -y git g++ software-properties-common build-essential language-pack-en unzip curl wget vim libpam0g-dev libssl-dev cmake cron libssl-dev openssl iputils-ping
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
RUN echo "sleep infinity" >> /temp/hadoop/hadoop-3.3.1/sbin/start-all.sh

WORKDIR /temp
CMD /temp/hadoop/hadoop-3.3.1/sbin/start-all.sh 
