FROM --platform=$TARGETPLATFORM alpine:edge as builder

LABEL org.opencontainers.image.authors="fanite"

ENV TZ Asia/Shanghai

COPY ./scripts /scripts

RUN chmod +x /scripts/*.sh

RUN set -ex \
    && apk update \
    && apk add --no-cache --virtual .build-deps alpine-conf sudo git curl libc-dev gcc g++ make

RUN /sbin/setup-timezone -z Asia/Shanghai

WORKDIR /working

RUN git clone https://github.com/flow2000/lookbusy.git \
    && cd lookbusy \
    && chmod +x ./configure \
    && ./configure \
    && make

RUN apk del .build-deps \
    && apk add --no-cache speedtest-cli \
    && cp /working/lookbusy/lookbusy /usr/bin/lookbusy

FROM --platform=$TARGETPLATFORM alpine:latest

ENV TZ Asia/Shanghai

COPY ./scripts /scripts

RUN chmod +x /scripts/*.sh

COPY --from=builder /working/lookbusy/lookbusy /usr/bin/lookbusy

RUN apk add --no-cache speedtest-cli

RUN echo -e "0 30  2 * * ? /bin/sh -ec timeout -k 0 2h /script/lookbusy.sh 2>&1 &">/var/spool/cron/crontabs/root \
    && echo -e "0 0 0/2 * * ? /bin/sh -ec /script/speedtest.sh 2>&1 &">>/var/spool/cron/crontabs/root

USER root
