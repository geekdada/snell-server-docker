FROM --platform=$BUILDPLATFORM alpine:3.21 AS build

COPY get_url.sh /get_url.sh
ARG TARGETARCH
ARG VERSION
RUN wget -q -O "snell-server.zip" "$(/get_url.sh "${VERSION}" "${TARGETARCH}")" && \
    unzip snell-server.zip && rm snell-server.zip

FROM debian:bookworm-slim

ENV TZ=UTC

COPY --from=build /snell-server /usr/bin/snell-server
COPY start.sh /start.sh
RUN apt-get update && \
    apt-get install -y --no-install-recommends libstdc++6 && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/start.sh"]
