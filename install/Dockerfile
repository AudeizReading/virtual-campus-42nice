FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /tmp/corrections
COPY . .
WORKDIR /usr/src/norminette
RUN apt -y upgrade \
	&& apt update -y \
	&& apt install -y \
	gcc \
	g++ \
	make \
	gdb \
	valgrind \
	vim \
	software-properties-common \
	&& apt update -y \
	&& add-apt-repository ppa:deadsnakes/ppa -y \
	&& apt update -y \
	&& apt install -y python3.11 python3-pip \
	&& python3 -m pip install --upgrade pip setuptools \
	&& python3 -m pip install norminette \
	&& rm -rf /tmp/corrections/Dockerfile
WORKDIR /tmp/corrections
ENTRYPOINT [ "/bin/bash" ]
