#!/bin/bash

mkdir -p /var/lib/lokinet
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