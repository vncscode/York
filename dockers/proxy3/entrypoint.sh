#!/bin/bash
cd /home/container

# Make internal Docker IP address available to processes.
export INTERNAL_IP=`ip route get 1 | awk '{print $(NF-2);exit}'`

# --- Variable Defaults ---
SERVER_PORT=${SERVER_PORT:-1080}
PROXY_USER=${PROXY_USER:-user}
PROXY_PASSWORD=${PROXY_PASSWORD:-password}
DNS_PRIMARY=${DNS_PRIMARY:-8.8.8.8}
DNS_SECONDARY=${DNS_SECONDARY:-8.8.4.4}
MAX_CONNECTIONS=${MAX_CONNECTIONS:-500}
USER_CONN_LIMIT=${USER_CONN_LIMIT:-50}
BANDWIDTH_IN=${BANDWIDTH_IN:-0}
BANDWIDTH_OUT=${BANDWIDTH_OUT:-0}
HTTP_PROXY_PORT=${HTTP_PROXY_PORT:-3128}

echo "Generating 3proxy configuration..."
echo "User: ${PROXY_USER}"
echo "SOCKS5 Port: ${SERVER_PORT}"
if [ "${HTTP_PROXY_PORT}" -gt "0" ]; then
    echo "HTTP Proxy Port: ${HTTP_PROXY_PORT}"
else
    echo "HTTP Proxy: Disabled"
fi

# --- Config Generation ---
cat <<EOF > 3proxy.cfg
# Globals
nserver ${DNS_PRIMARY}
nserver ${DNS_SECONDARY}
nscache 65536
timeouts 1 5 30 60 180 1800 15 60
maxconn ${MAX_CONNECTIONS}

# Logging (Stdout)
log

# Authentication
auth strong
users "${PROXY_USER}:CL:${PROXY_PASSWORD}"

# --- Bandwidth & Connection Limits ---
# Apply to all users (*), all sources (*), all targets (*), all ports (*)
EOF

# Connection Limit per User
if [ "${USER_CONN_LIMIT}" -gt "0" ]; then
    echo "connlim ${USER_CONN_LIMIT} 0 * *" >> 3proxy.cfg
fi

# Bandwidth Limits (bps)
if [ "${BANDWIDTH_IN}" -gt "0" ]; then
    echo "bandlimin ${BANDWIDTH_IN} * *" >> 3proxy.cfg
fi
if [ "${BANDWIDTH_OUT}" -gt "0" ]; then
    echo "bandlimout ${BANDWIDTH_OUT} * *" >> 3proxy.cfg
fi

# --- Services ---
cat <<EOF >> 3proxy.cfg

# Access Control
allow "${PROXY_USER}"

# SOCKS5 Proxy
socks -p${SERVER_PORT}
EOF

# HTTP Proxy (Optional)
if [ "${HTTP_PROXY_PORT}" -gt "0" ]; then
    echo "proxy -p${HTTP_PROXY_PORT}" >> 3proxy.cfg
fi

echo "flush" >> 3proxy.cfg

# --- Startup Execution ---
# Replace Startup Variables
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo -e ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
eval ${MODIFIED_STARTUP}