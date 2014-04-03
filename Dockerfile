FROM phusion/baseimage:0.9.9
MAINTAINER examples@docker.io


# Set correct environment variables.
ENV HOME /root

# Regenerate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

RUN apt-get update && apt-get -qqy install nginx-extras openjdk-6-jre wget

ENV JAVA_HOME /usr/lib/jvm/java-6-openjdk-amd64

RUN mkdir /etc/service/nginx
ADD runit/nginx.sh /etc/service/nginx/run
RUN chmod +x /etc/service/nginx/run && chown root:root /etc/service/nginx/run
ADD nginx.conf /etc/nginx/nginx.conf

RUN wget https://download.elasticsearch.org/kibana/kibana/kibana-3.0.0.tar.gz
RUN tar xzf kibana-3.0.0.tar.gz
RUN cp -rf kibana-3.0.0/* /usr/share/nginx/www/

RUN wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.1.0.tar.gz
RUN tar xzf elasticsearch-1.1.0.tar.gz
RUN mv elasticsearch-1.1.0 /opt/elasticsearch
RUN rm elasticsearch-1.1.0.tar.gz

RUN mkdir /etc/service/elasticsearch
ADD runit/elasticsearch.sh /etc/service/elasticsearch/run
RUN chmod +x /etc/service/elasticsearch/run && chown root:root /etc/service/elasticsearch/run

RUN /usr/sbin/enable_insecure_key

EXPOSE 80 443
EXPOSE 9200 9300


# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*