#!/bin/bash
cd /home/container

# Make internal Docker IP address available to processes.
export INTERNAL_IP=`ip route get 1 | awk '{print $(NF-2);exit}'`

# Ensure variables are set
SERVER_PORT=${SERVER_PORT:-1080}
PROXY_USER=${PROXY_USER:-user}
PROXY_PASSWORD=${PROXY_PASSWORD:-password}

echo "Configuring 3proxy SOCKS5 on port ${SERVER_PORT}..."

# Create 3proxy config
# Using 'auth strong' requires users list
# We configure SOCKS5 on SERVER_PORT
cat <<EOF > 3proxy.cfg
nserver 8.8.8.8
nserver 8.8.4.4
nscache 65536
timeouts 1 5 30 60 180 1800 15 60
daemon
auth strong
users ${PROXY_USER}:CL:${PROXY_PASSWORD}
allow ${PROXY_USER}
socks -p${SERVER_PORT}
flush
EOF

# Run the Server
echo "Starting 3proxy..."
# Executing directly keeps the process as PID 1 or child of entrypoint, ensuring signals are handled
exec 3proxy 3proxy.cfg