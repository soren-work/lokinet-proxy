FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV SOCKS_PORT=1080 

# Added ca-certificates because slim images may not have it by default, which causes curl HTTPS certificate errors
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl gnupg iptables iproute2 dante-server net-tools jq ca-certificates && \
    curl -so /etc/apt/trusted.gpg.d/oxen.gpg https://deb.oxen.io/pub.gpg && \
    # Changed source version from jammy (Ubuntu) to bookworm (Debian 12)
    echo "deb https://deb.oxen.io bookworm main" > /etc/apt/sources.list.d/oxen.list && \
    apt-get update && apt-get install -y --no-install-recommends lokinet && \
    # Clean apt cache, this step is key to keeping the image small
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY docker-entrypoint.sh /docker-entrypoint
RUN chmod +x /docker-entrypoint

EXPOSE ${SOCKS_PORT}

CMD ["/docker-entrypoint"]