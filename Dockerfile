FROM --platform=$BUILDPLATFORM tonistiigi/xx:latest AS xx

FROM --platform=$BUILDPLATFORM frolvlad/alpine-glibc:alpine-3.21 AS build

COPY --from=xx / /
COPY get_url.sh /get_url.sh
ARG TARGETPLATFORM
ARG VERSION

RUN xx-info env && wget -q -O "snell-server.zip" $(/get_url.sh ${VERSION} $(xx-info arch)) && \
    unzip snell-server.zip && rm snell-server.zip && \
    xx-verify /snell-server

FROM --platform=$TARGETPLATFORM frolvlad/alpine-glibc:alpine-3.21

ENV TZ=UTC

COPY --from=build /snell-server /usr/bin/snell-server
COPY start.sh /start.sh
RUN apk add --update --no-cache libstdc++

ENTRYPOINT /start.sh
