#添加基本系统 start kevin、2016/06/29

# alexindigo/ubuntu_precise
FROM ubuntu:12.04
MAINTAINER kevinjiang <jiangxingkai@fmbj.com.cn>

# Make DEBIAN_FRONTEND less chatty
ENV DEBIAN_FRONTEND noninteractive

# Update stuff
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list && apt-get update && apt-get upgrade -y

# Dev essential dependencies
RUN apt-get install -y build-essential curl

#添加基本系统 end kevin、2016/06/29



#添加基础 start kevin、2016/06/29
#FROM ubuntu:precise

ENV HOME /home

# Add apt repository needed
RUN echo 'deb http://archive.ubuntu.com/ubuntu precise main universe' > /etc/apt/sources.list  && \
    echo 'deb http://archive.ubuntu.com/ubuntu precise-security main universe' >> /etc/apt/sources.list && \
    echo 'deb http://archive.ubuntu.com/ubuntu precise-updates main universe' >> /etc/apt/sources.list && \
    echo 'deb http://archive.ubuntu.com/ubuntu precise-backports main restricted universe multiverse' >> /etc/apt/sources.list && \
    echo 'deb-src http://archive.ubuntu.com/ubuntu precise main universe' >> /etc/apt/sources.list && \
    echo 'deb-src http://archive.ubuntu.com/ubuntu precise-security main universe' >> /etc/apt/sources.list && \
    echo 'deb-src http://archive.ubuntu.com/ubuntu precise-updates main universe' >> /etc/apt/sources.list && \
    echo 'deb-src http://archive.ubuntu.com/ubuntu precise-backports main restricted universe multiverse' >> /etc/apt/sources.list && \
    mkdir -p $HOME && \
    apt-get update && \
    apt-get install -y python-software-properties python-pip git curl wget sudo socat && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ADD Travis User
RUN addgroup --gid=1000 travis && \
    adduser --system --uid=1000 --home /home --shell /bin/bash travis && \
    echo "travis ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    chown -R travis:travis /home && \
    chown -R travis:travis /usr/local

USER travis
#添加基础 end kevin、2016/06/29


#修改掉原来的继承关系 kevin、2016/06/29
#FROM node:0.10
#MAINTAINER kevinjiang <jiangxingkai@fmbj.com.cn>
# Based on work by osm map

# make sure the mapbox fonts are available on the system
RUN mkdir -p /tmp/mapbox-studio-default-fonts && \
    mkdir -p /fonts && \
    git clone https://github.com/mapbox/mapbox-studio-default-fonts.git /tmp/mapbox-studio-default-fonts && \
    cp /tmp/mapbox-studio-default-fonts/**/*.otf /fonts && \
    cp /tmp/mapbox-studio-default-fonts/**/*.ttf /fonts && \
    rm -rf /tmp/mapbox-studio-default-fonts

# download fonts required for osm bright
RUN wget -q -P /fonts https://github.com/aaronlidman/Toner-for-Tilemill/raw/master/toner4tilemill/fonts/Arial-Bold.ttf && \
    wget -q -P /fonts https://github.com/aaronlidman/Toner-for-Tilemill/raw/master/toner4tilemill/fonts/Arial-Regular.ttf && \
    wget -q -P /fonts https://github.com/aaronlidman/Toner-for-Tilemill/raw/master/toner4tilemill/fonts/Arial-Unicode-Bold-Italic.ttf && \
    wget -q -P /fonts https://github.com/aaronlidman/Toner-for-Tilemill/raw/master/toner4tilemill/fonts/Arial-Unicode-Bold.ttf && \
    wget -q -P /fonts https://github.com/aaronlidman/Toner-for-Tilemill/raw/master/toner4tilemill/fonts/Arial-Unicode-Italic.ttf && \
    wget -q -P /fonts https://github.com/aaronlidman/Toner-for-Tilemill/raw/master/toner4tilemill/fonts/Arial-Unicode-Regular.ttf

ENV MAPNIK_FONT_PATH=/fonts

RUN mkdir -p /usr/src/app && mkdir -p /project
WORKDIR /usr/src/app
# only install minimal amount of tessera packages
# be careful as some tessera packages collide with itself
RUN npm install \
    mbtiles@0.8.2  \
    tilelive-tmstyle@0.4.2 \
    tilelive-xray@0.2.0  \
    tilelive-http@0.8.0

COPY / /usr/src/app
RUN npm install

VOLUME /data
ENV SOURCE_DATA_DIR=/data \
    DEST_DATA_DIR=/project \
    PORT=80 \
    MAPNIK_FONT_PATH=/fonts \
    DOMAINS=

EXPOSE 80
CMD ["/usr/src/app/run.sh"]
