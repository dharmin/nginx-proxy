FROM nginx:1.13
LABEL maintainer="Jason Wilder mail@jasonwilder.com"

# Install wget and install/updates certificates
RUN apt-get update \
 && apt-get install -y -q --no-install-recommends \
    ca-certificates \
    wget \
 && apt-get clean \
 && rm -r /var/lib/apt/lists/*


# Configure Nginx and apply fix for very long server names
RUN echo "daemon off;" >> /etc/nginx/nginx.conf \
 && sed -i 's/worker_processes  1/worker_processes  auto/' /etc/nginx/nginx.conf

# Install Forego
# ADD https://github.com/jwilder/forego/releases/download/v0.16.1/forego /usr/local/bin/forego
RUN wget https://github.com/jwilder/forego/releases/download/v0.16.1/forego -O /usr/local/bin/forego
RUN chmod u+x /usr/local/bin/forego

ENV DOCKER_GEN_VERSION 0.7.3

RUN wget https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz \
	&& tar -C /usr/local/bin -xvzf docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz \
	&& rm /docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz


COPY network_internal.conf /etc/nginx/


COPY . /app/
WORKDIR /app/


# ENV GOSU_VERSION 1.10
# RUN set -ex \
# 	&& apt-get update \
# 	&& apt-get install -y --no-install-recommends 	ca-certificates wget gnupg gnupg2 dirmngr \
# 	&& rm -rf /var/lib/apt/lists/* \
# 	&& dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
# 	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.10/gosu-$(dpkg --print-architecture)" \
# 	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.10/gosu-$(dpkg --print-architecture).asc" \
# 	&& export GNUPGHOME="$(mktemp -d)" \
# 	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
# 	&& rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
# 	&& chmod +x /usr/local/bin/gosu \
# 	&& gosu nobody true 
#	&& apt-get purge -y --auto-remove ca-certificates wget dirmngr  gnupg gnupg2

ENV DOCKER_HOST unix:///tmp/docker.sock

VOLUME ["/etc/nginx/certs", "/etc/nginx/dhparam"]

ENTRYPOINT ["/app/docker-entrypoint.sh"]

CMD ["forego", "start", "-r"]
