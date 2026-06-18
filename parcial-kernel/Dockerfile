FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    nasm \
    xorriso \
    grub-pc-bin \
    grub-common \
    mtools \
    dosfstools \
    && apt-get clean

VOLUME /root/env
WORKDIR /root/env