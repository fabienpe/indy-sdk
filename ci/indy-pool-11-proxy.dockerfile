# Docker file that starts 11 Indy nodes and setup ports so that Toxiproxy can easily be
# configured to work with them. Genesis file indicates note ports 9701, etc. but nodes
# listen on 9801. Toxiproxy should forward between 9701 and 9801.
#
# Toxiproxy:
#   https://github.com/shopify/toxiproxy
#
# Docker port configuration:
#    https://docs.docker.com/engine/reference/run/
#    https://codability.in/docker-networking-explained/
#
# Usage:
# docker build --build-arg pool_ip=<IP_ADDRESS> -f ci/indy-pool-11.dockerfile -t indy_pool_11_proxy .
# docker run -itd --name indy_pool_11 -p 9801:9801 -p 9803:9803 -p 9805:9805 -p 9807:9807 -p 9809:9809 -p 9811:9811 -p 9813:9813 -p 9815:9815 -p 9817:9817 -p 9819:9819 -p 9821:9821 -p 9702:9702 -p 9704:9704 -p 9706:9706 -p 9708:9708 -p 9710:9710 -p 9712:9712 -p 9714:9714 -p 9716:9716 -p 9718:9718 -p 9720:9720 indy_pool_11_proxy
#
# Checking ports:
# docker port indy_pool_11
# sudo netstat -tunlp  | grep docker-proxy

FROM ubuntu:16.04

ARG uid=1000

# Install environment
RUN apt-get update -y && apt-get install -y \
	git \
	wget \
	python3.5 \
	python3-pip \
	python-setuptools \
	python3-nacl \
	apt-transport-https \
	ca-certificates \
	supervisor

RUN pip3 install -U \
	pip==9.0.3 \
	setuptools

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys CE7709D068DB5E88
ARG indy_stream=master
RUN echo "deb https://repo.sovrin.org/deb xenial $indy_stream" >> /etc/apt/sources.list

RUN useradd -ms /bin/bash -u $uid indy

ARG indy_plenum_ver=1.9.2~dev871
ARG indy_node_ver=1.9.2~dev1061
ARG python3_indy_crypto_ver=0.4.5
ARG indy_crypto_ver=0.4.5
ARG python3_pyzmq_ver=17.0.0

RUN apt-get update -y && apt-get install -y \
        python3-pyzmq=${python3_pyzmq_ver} \
        indy-plenum=${indy_plenum_ver} \
        indy-node=${indy_node_ver} \
        python3-indy-crypto=${python3_indy_crypto_ver} \
        libindy-crypto=${indy_crypto_ver} \
        vim

RUN echo "[supervisord]\n\
logfile = /tmp/supervisord.log\n\
logfile_maxbytes = 50MB\n\
logfile_backups=10\n\
logLevel = error\n\
pidfile = /tmp/supervisord.pid\n\
nodaemon = true\n\
minfds = 1024\n\
minprocs = 200\n\
umask = 022\n\
user = indy\n\
identifier = supervisor\n\
directory = /tmp\n\
nocleanup = true\n\
childlogdir = /tmp\n\
strip_ansi = false\n\
\n\
[program:node1]\n\
command=start_indy_node Node1 0.0.0.0 9801 0.0.0.0 9702\n\
directory=/home/indy\n\
stdout_logfile=/tmp/node1.log\n\
stderr_logfile=/tmp/node1.log\n\
\n\
[program:node2]\n\
command=start_indy_node Node2 0.0.0.0 9803 0.0.0.0 9704\n\
directory=/home/indy\n\
stdout_logfile=/tmp/node2.log\n\
stderr_logfile=/tmp/node2.log\n\
\n\
[program:node3]\n\
command=start_indy_node Node3 0.0.0.0 9805 0.0.0.0 9706\n\
directory=/home/indy\n\
stdout_logfile=/tmp/node3.log\n\
stderr_logfile=/tmp/node3.log\n\
\n\
[program:node4]\n\
command=start_indy_node Node4 0.0.0.0 9807 0.0.0.0 9708\n\
directory=/home/indy\n\
stdout_logfile=/tmp/node4.log\n\
stderr_logfile=/tmp/node4.log\n\
\n\
[program:node5]\n\
command=start_indy_node Node5 0.0.0.0 9809 0.0.0.0 9710\n\
directory=/home/indy\n\
stdout_logfile=/tmp/node5.log\n\
stderr_logfile=/tmp/node5.log\n\
\n\
[program:node6]\n\
command=start_indy_node Node6 0.0.0.0 9811 0.0.0.0 9712\n\
directory=/home/indy\n\
stdout_logfile=/tmp/node6.log\n\
stderr_logfile=/tmp/node6.log\n\
\n\
[program:node7]\n\
command=start_indy_node Node7 0.0.0.0 9813 0.0.0.0 9714\n\
directory=/home/indy\n\
stdout_logfile=/tmp/node7.log\n\
stderr_logfile=/tmp/node7.log\n\
\n\
[program:node8]\n\
command=start_indy_node Node8 0.0.0.0 9815 0.0.0.0 9716\n\
directory=/home/indy\n\
stdout_logfile=/tmp/node8.log\n\
stderr_logfile=/tmp/node8.log\n\
\n\
[program:node9]\n\
command=start_indy_node Node9 0.0.0.0 9817 0.0.0.0 9718\n\
directory=/home/indy\n\
stdout_logfile=/tmp/node9.log\n\
stderr_logfile=/tmp/node9.log\n\
\n\
[program:node10]\n\
command=start_indy_node Node10 0.0.0.0 9819 0.0.0.0 9720\n\
directory=/home/indy\n\
stdout_logfile=/tmp/node10.log\n\
stderr_logfile=/tmp/node10.log\n\
\n\
[program:node11]\n\
command=start_indy_node Node11 0.0.0.0 9821 0.0.0.0 9722\n\
directory=/home/indy\n\
stdout_logfile=/tmp/node11.log\n\
stderr_logfile=/tmp/node11.log\n"\
>> /etc/supervisord.conf

USER indy

RUN awk '{if (index($1, "NETWORK_NAME") != 0) {print("NETWORK_NAME = \"sandbox\"")} else print($0)}' /etc/indy/indy_config.py> /tmp/indy_config.py
RUN echo "\nlogLevel=20\n" >> /tmp/indy_config.py
RUN mv /tmp/indy_config.py /etc/indy/indy_config.py

ARG pool_ip=127.0.0.1

RUN generate_indy_pool_transactions --nodes 11 --clients 12 --nodeNum 1 2 3 4 5 6 7 8 9 10 11 --ips="$pool_ip,$pool_ip,$pool_ip,$pool_ip,$pool_ip,$pool_ip,$pool_ip,$pool_ip,$pool_ip,$pool_ip,$pool_ip"

EXPOSE 9801 9702 9803 9704 9805 9706 9807 9708 9809 9710 9811 9712 9813 9714 9815 9716 9817 9718 9819 9720 9821 9722

CMD ["/usr/bin/supervisord"]
