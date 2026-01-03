#!/bin/bash
cd /home/container

export INTERNAL_IP=`ip route get 1 | awk '{print $(NF-2);exit}'`

SERVER_PORT=${SERVER_PORT:-1080}

echo "Configuring Dante SOCKS5 on port ${SERVER_PORT}..."

# Note: Authentication in Dante usually requires system users.
# Running as non-root user 'container' makes adding system users impossible at runtime.
# This configuration defaults to NO AUTHENTICATION (username none) unless pre-configured.
# To use auth, we would need to run as root or mount a password file that dante can read/verify,
# but dante's 'username' method relies on getpwnam().

cat <<EOF > sockd.conf
logoutput: stderr
internal: 0.0.0.0 port = ${SERVER_PORT}
external: eth0
socksmethod: none
clientmethod: none
user.privileged: root
user.unprivileged: container
user.libwrap: nobody

client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: error
}

socks pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: error
}
EOF

echo "Starting Dante..."
exec sockd -f sockd.conf