FROM --platform=$TARGETPLATFORM alpine:edge as builder

LABEL org.opencontainers.image.authors="fanite"

ENV TZ Asia/Shanghai

RUN set -ex \
    && apk update \
    && apk add --no-cache speedtest-cli \
    && apk add --no-cache --virtual .build-deps alpine-conf sudo git curl libc-dev gcc g++ make

RUN /sbin/setup-timezone -z Asia/Shanghai

WORKDIR /working

RUN git clone https://github.com/flow2000/lookbusy.git \
    && cd lookbusy \
    && chmod +x ./configure \
    && ./configure \
    && make

RUN cp /working/lookbusy/lookbusy /usr/bin

COPY ./scripts /scripts

RUN chmod +x /scripts/*.sh

ENTRYPOINT ['/usr/bin/lookbusy', '-h']

USER root
