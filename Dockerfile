FROM ubuntu:trusty

ENV DEBIAN_FRONTEND noninteractive
ENV PATH $PATH:/usr/local/nginx/sbin

EXPOSE 1935
EXPOSE 80
EXPOSE 443

# create directories
RUN mkdir /src /config /logs /data /static

# update and upgrade packages
RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get clean && \
  apt-get install -y --no-install-recommends build-essential \
  wget software-properties-common ufw && \
# ffmpeg
  add-apt-repository ppa:mc3man/trusty-media && \
  apt-get update && \
  apt-get install -y --no-install-recommends ffmpeg && \
# nginx dependencies
  apt-get install -y --no-install-recommends libpcre3-dev \
  zlib1g-dev libssl-dev wget

# get nginx source
WORKDIR /src
RUN wget http://nginx.org/download/nginx-1.7.5.tar.gz && \
  tar zxf nginx-1.7.5.tar.gz && \
  rm nginx-1.7.5.tar.gz && \
# get nginx-rtmp module
  wget https://github.com/arut/nginx-rtmp-module/archive/v1.1.6.tar.gz && \
  tar zxf v1.1.6.tar.gz && \
  rm v1.1.6.tar.gz

# compile nginx
WORKDIR /src/nginx-1.7.5
RUN ./configure --add-module=/src/nginx-rtmp-module-1.1.6 \
  --conf-path=/config/nginx.conf \
  --error-log-path=/logs/error.log \
  --http-log-path=/logs/access.log && \
  make && \
  make install

ADD nginx.conf /config/nginx.conf
ADD static /static
ADD player /player

# get letsencrypt
#RUN add-apt-repository ppa:certbot/certbot && \
#  apt-get update && \
#  apt-get install -y python-certbot-nginx

# configure ufw
#RUN sudo ufw allow ssh && \
#  sudo ufw allow 80 && \
#  sudo ufw allow 443 && \
#  sudo ufw allow from 98.117.12.36 to any port 1935 && \
#  sudo ufw default deny incoming && \
#  sudo ufw default allow outgoing && \
#  sudo ufw enable

WORKDIR /
CMD "nginx" && \
RUN certbot --nginx -d transcendence.do.networkgeek.cloud -m geoff@networkgeek.cloud --agree-tos --non-interactive
