# docker build --build-arg pool_ip=10.132.3.6 -f ci/indy-pool-11.dockerfile -t indy_pool_11 .
# docker run -itd -p 10.132.3.6:9701-9722:9701-9722 indy_pool_11


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

ARG indy_plenum_ver=1.9.1~dev856
ARG indy_node_ver=1.9.1~dev1043
ARG python3_indy_crypto_ver=0.4.5
ARG indy_crypto_ver=0.4.5

RUN apt-get update -y && apt-get install -y \
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
command=start_indy_node Node1 0.0.0.0 9701 0.0.0.0 9702\n\
directory=/home/indy\n\
stdout_logfile=/tmp/node1.log\n\
stderr_logfile=/tmp/node1.log\n\
\n\
[program:node2]\n\
command=start_indy_node Node2 0.0.0.0 9703 0.0.0.0 9704\n\
directory=/home/indy\n\
stdout_logfile=/tmp/node2.log\n\
stderr_logfile=/tmp/node2.log\n\
\n\
[program:node3]\n\
command=start_indy_node Node3 0.0.0.0 9705 0.0.0.0 9706\n\
directory=/home/indy\n\
stdout_logfile=/tmp/node3.log\n\
stderr_logfile=/tmp/node3.log\n\
\n\
[program:node4]\n\
command=start_indy_node Node4 0.0.0.0 9707 0.0.0.0 9708\n\
directory=/home/indy\n\
stdout_logfile=/tmp/node4.log\n\
stderr_logfile=/tmp/node4.log\n\
\n\
[program:node5]\n\
command=start_indy_node Node5 0.0.0.0 9709 0.0.0.0 9710\n\
directory=/home/indy\n\
stdout_logfile=/tmp/node5.log\n\
stderr_logfile=/tmp/node5.log\n\
\n\
[program:node6]\n\
command=start_indy_node Node6 0.0.0.0 9711 0.0.0.0 9712\n\
directory=/home/indy\n\
stdout_logfile=/tmp/node6.log\n\
stderr_logfile=/tmp/node6.log\n\
\n\
[program:node7]\n\
command=start_indy_node Node7 0.0.0.0 9713 0.0.0.0 9714\n\
directory=/home/indy\n\
stdout_logfile=/tmp/node7.log\n\
stderr_logfile=/tmp/node7.log\n\
\n\
[program:node8]\n\
command=start_indy_node Node8 0.0.0.0 9715 0.0.0.0 9716\n\
directory=/home/indy\n\
stdout_logfile=/tmp/node8.log\n\
stderr_logfile=/tmp/node8.log\n\
\n\
[program:node9]\n\
command=start_indy_node Node9 0.0.0.0 9717 0.0.0.0 9718\n\
directory=/home/indy\n\
stdout_logfile=/tmp/node9.log\n\
stderr_logfile=/tmp/node9.log\n\
\n\
[program:node10]\n\
command=start_indy_node Node10 0.0.0.0 9719 0.0.0.0 9720\n\
directory=/home/indy\n\
stdout_logfile=/tmp/node10.log\n\
stderr_logfile=/tmp/node10.log\n\
\n\
[program:node11]\n\
command=start_indy_node Node11 0.0.0.0 9721 0.0.0.0 9722\n\
directory=/home/indy\n\
stdout_logfile=/tmp/node11.log\n\
stderr_logfile=/tmp/node11.log\n"\
>> /etc/supervisord.conf

USER indy

RUN awk '{if (index($1, "NETWORK_NAME") != 0) {print("NETWORK_NAME = \"sandbox\"")} else print($0)}' /etc/indy/indy_config.py> /tmp/indy_config.py
RUN mv /tmp/indy_config.py /etc/indy/indy_config.py

ARG pool_ip=127.0.0.1

RUN generate_indy_pool_transactions --nodes 11 --clients 12 --nodeNum 1 2 3 4 5 6 7 8 9 10 11 --ips="$pool_ip,$pool_ip,$pool_ip,$pool_ip,$pool_ip,$pool_ip,$pool_ip,$pool_ip,$pool_ip,$pool_ip,$pool_ip"

EXPOSE 9701 9702 9703 9704 9705 9706 9707 9708 9709 9710 9711 9712 9713 9714 9715 9716 9717 9718 9719 9720 9721 9722
CMD ["/usr/bin/supervisord"]
