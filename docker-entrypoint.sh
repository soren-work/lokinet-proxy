#!/bin/bash

echo "nameserver 127.3.2.1" > /tmp/resolv.conf
echo "nameserver 1.1.1.1" >> /tmp/resolv.conf
cat /tmp/resolv.conf > /etc/resolv.conf || true
echo "DNS forcibly set to 127.3.2.1"

mkdir -p /var/lib/lokinet

echo "Generating lokinet.ini from environment variables..."
cat <<EOF > /var/lib/lokinet/lokinet.ini
[router]
worker-threads=${LOKINET_WORKER_THREADS}

[network]
hops=${LOKINET_HOPS}
paths=${LOKINET_PATHS}
persist-addrmap-file=/var/lib/lokinet/addrmap.dat

[dns]
upstream=${LOKINET_UPSTREAM_DNS}
EOF
echo "lokinet.ini generated successfully."

echo "Starting lokinet daemon..."
lokinet &

echo "Waiting for lokitun0 interface..."
while ! ip link show lokitun0 > /dev/null 2>&1; do
  sleep 1
done
echo "lokitun0 interface is up!"

# Dynamically generate Dante configuration using environment variables
cat <<EOF > /etc/danted.conf
logoutput: stderr
internal: 0.0.0.0 port = ${SOCKS_PORT}
external: lokitun0
clientmethod: none
socksmethod: none
user.privileged: root
user.notprivileged: nobody
client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: connect error
}
socks pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: connect error
}
EOF

echo "Starting SOCKS5 proxy on 0.0.0.0:${SOCKS_PORT}..."
exec danted -f /etc/danted.conf