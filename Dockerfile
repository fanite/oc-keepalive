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

RUN echo -e "0 30  2 * * ? /usr/bin/timeout -k 0 2h /bin/sh /scripts/lookbusy.sh>/var/log/lookbusy.log 2>&1 &">/var/spool/cron/crontabs/root \
    && echo -e "0 0 0/2 * * ? /bin/sh /scripts/speedtest.sh>/var/log/speedtest.log 2>&1 &">>/var/spool/cron/crontabs/root

USER root

CMD ["cron","-f", "-L", "2"]
