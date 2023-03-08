FROM --platform=$TARGETPLATFORM alpine:edge as builder

LABEL org.opencontainers.image.authors="fanite"

ENV TZ Asia/Shanghai

RUN set -ex \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && apk update \
    && apk add --no-cache speedtest
    && apk add --no-cache --virtual .build-deps alpine-conf git curl libc-dev gcc g++ make cmake

RUN /sbin/setup-timezone -z Asia/Shanghai

WORKDIR /working

RUN git clone https://github.com/flow2000/lookbusy.git \
    && cd lookbusy \
    && chmod +x ./configure \
    && ./configure \
    && make \
    && make install

COPY ./scripts /scripts

RUN chmod +x /scripts/*.sh

ENTRYPOINT ['/usr/bin/lookbusy', '-h']

USER root
