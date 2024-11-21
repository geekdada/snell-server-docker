#!/bin/ash

set -e

BIN="/usr/bin/snell-server"
CONF="/etc/snell-server.conf"

# reuse existing config when the container restarts

run_bin() {
    echo "Running snell-server with config:"
    echo ""
    cat ${CONF}

    ${BIN} --version
    ${BIN} -c ${CONF}
}

if [ -f ${CONF} ]; then
    echo "Found existing config, rm it."
    rm ${CONF}
fi

if [ -z ${PSK} ]; then
    PSK=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 16)
    echo "Using generated PSK: ${PSK}"
else
    echo "Using predefined PSK: ${PSK}"
fi

if [ -z ${PORT} ]; then
    PORT=9102
    echo "Using default PORT: ${PORT}"
else
    echo "Using predefined PORT: ${PORT}"
fi

echo "Generating new config..."
echo "[snell-server]" >> ${CONF}
echo "listen = :::${PORT}" >> ${CONF}
echo "psk = ${PSK}" >> ${CONF}

run_bin
