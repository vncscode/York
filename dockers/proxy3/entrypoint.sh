#!/bin/bash
cd /home/container

# Make internal Docker IP address available to processes.
export INTERNAL_IP=`ip route get 1 | awk '{print $(NF-2);exit}'`

# Ensure variables are set for the config generation
SERVER_PORT=${SERVER_PORT:-1080}
PROXY_USER=${PROXY_USER:-user}
PROXY_PASSWORD=${PROXY_PASSWORD:-password}

echo "Generating 3proxy configuration..."

# Create 3proxy.cfg based on documentation
# Note: 'daemon' is OMITTED to keep it in foreground for Docker
cat <<EOF > 3proxy.cfg
nserver 8.8.8.8
nserver 8.8.4.4
nscache 65536
timeouts 1 5 30 60 180 1800 15 60

# Log to stdout
log

# Authentication
auth strong
users "${PROXY_USER}:CL:${PROXY_PASSWORD}"
allow "${PROXY_USER}"

# Services
socks -p${SERVER_PORT}
proxy -p3128

flush
EOF

# Replace Startup Variables (Pterodactyl Standard)
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo -e ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
eval ${MODIFIED_STARTUP}