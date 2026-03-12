# Lokinet Proxy

A lightweight **Docker** image for running [**Lokinet**](https://lokinet.io/) as a **SOCKS5 proxy** - a decentralized, privacy-preserving network built on the Oxen blockchain.

This project provides an optimized **Docker** container that runs **Lokinet** as a **SOCKS5 proxy**, enabling you to route all your traffic through the **Lokinet** decentralized network with minimal configuration. Perfect for privacy-conscious users who want to leverage **Lokinet**'s anonymous routing capabilities through a simple **Docker** deployment.

## Features

- 🔒 **Privacy-First**: Route your traffic through Lokinet's decentralized network
- 🐳 **Docker Native**: Simple containerized deployment with Docker and Docker Compose
- 📦 **Lightweight**: Based on Debian Bookworm slim image, optimized for low resource usage
- 🔄 **Auto-Updates**: GitHub Actions workflow automatically builds images with the latest Lokinet releases
- 🛡️ **Secure by Default**: Uses principle of least privilege with minimal required capabilities
- 🌐 **SOCKS5 Proxy**: Built-in Dante SOCKS5 server for easy integration with other services

## Quick Start

### Using Docker Compose (Recommended)

1. Clone this repository:
```bash
git clone https://github.com/soren-work/lokinet-proxy.git
cd lokinet-proxy
```

2. Update the image address in `docker-compose.yml`:
```yaml
image: ghcr.io/<your-github-username>/lokinet-proxy:latest
```

3. Start the container:
```bash
docker-compose up -d
```

4. Verify Lokinet is running:
```bash
docker-compose logs lokinet
```

### Using Docker CLI

```bash
docker run -d \
  --name lokinet \
  --cap-add NET_ADMIN \
  --cap-add NET_BIND_SERVICE \
  --device /dev/net/tun:/dev/net/tun \
  --sysctl net.ipv6.conf.all.disable_ipv6=0 \
  -e SOCKS_PORT=1080 \
  -v lokinet-data:/var/lib/lokinet \
  --restart unless-stopped \
  ghcr.io/<your-github-username>/lokinet-proxy:latest
```

## Configuration

### Environment Variables

- `SOCKS_PORT` (default: `1080`): The port on which the SOCKS5 proxy listens inside the container

### Docker Compose Configuration

The `docker-compose.yml` file includes several important settings:

#### Network Capabilities
```yaml
cap_add:
  - NET_ADMIN          # Required for network and routing configuration (lokitun0)
  - NET_BIND_SERVICE   # Required for binding to lower SOCKS5 ports
```

#### TUN Device
```yaml
devices:
  - /dev/net/tun:/dev/net/tun  # Required for Lokinet's virtual network interface
```

#### IPv6 Support
```yaml
sysctls:
  - net.ipv6.conf.all.disable_ipv6=0  # Lokinet requires IPv6
```

#### Data Persistence
```yaml
volumes:
  - ./data:/var/lib/lokinet  # Persists node keys and state
```

### Port Mapping

By default, the SOCKS5 port is **not exposed** to the host. Choose one of these approaches:

#### Local Testing Only
Uncomment in `docker-compose.yml` to expose only to localhost:
```yaml
ports:
  - "127.0.0.1:1080:1080"
```

#### Integration with Other Containers
If using with Xray/Marzban on the same Docker network, access via `lokinet:1080` without exposing the port.

#### Custom Network
To connect to an existing Docker network:
```yaml
networks:
  default:
    name: proxy_net
    external: true
```

## Usage Examples

### Using with curl
```bash
# Test SOCKS5 proxy (if port is exposed)
curl --socks5 127.0.0.1:1080 https://example.com
```

### Using with Firefox
1. Open Firefox Preferences → Network Settings
2. Configure SOCKS5 proxy: `127.0.0.1:1080`
3. Enable "Proxy DNS when using SOCKS v5"

### Integration with Xray/Marzban
If running Xray/Marzban in the same Docker network:
```yaml
# In your Xray config
"outbounds": [
  {
    "protocol": "socks",
    "settings": {
      "servers": [
        {
          "address": "lokinet",
          "port": 1080
        }
      ]
    }
  }
]
```

## Architecture

### How It Works

1. **Lokinet Daemon**: Runs the Lokinet client, creating a virtual `lokitun0` network interface
2. **Dante SOCKS5 Server**: Listens on the configured port and routes traffic through `lokitun0`
3. **Docker Entrypoint**: Orchestrates startup, waits for the TUN interface, and configures Dante dynamically

### Image Details

- **Base Image**: `debian:bookworm-slim`
- **Size**: Optimized for minimal footprint
- **Dependencies**: curl, gnupg, iptables, iproute2, dante-server, net-tools, jq, ca-certificates

## Automatic Updates

This repository includes a GitHub Actions workflow that:

- Checks for new Lokinet releases daily (2 AM UTC)
- Automatically builds and publishes Docker images to GitHub Container Registry
- Tags images with: `latest`, version number (e.g., `0.9.11`), and commit SHA
- Supports manual workflow dispatch for on-demand builds

### Image Tags

- `ghcr.io/<username>/lokinet-proxy:latest` - Latest release
- `ghcr.io/<username>/lokinet-proxy:0.9.11` - Specific version
- `ghcr.io/<username>/lokinet-proxy:abc1234` - Specific commit

## Troubleshooting

### Container won't start
```bash
# Check logs
docker-compose logs lokinet

# Verify TUN device is available
ls -la /dev/net/tun
```

### SOCKS5 proxy not responding
```bash
# Check if Dante is running
docker-compose exec lokinet ps aux | grep danted

# Test connectivity
docker-compose exec lokinet curl --socks5 127.0.0.1:1080 https://example.com
```

### IPv6 issues
Ensure the host system supports IPv6 and the sysctl setting is applied:
```bash
docker-compose exec lokinet sysctl net.ipv6.conf.all.disable_ipv6
```

## Security Considerations

- ✅ Uses principle of least privilege (no `privileged: true`)
- ✅ Only grants necessary capabilities (NET_ADMIN, NET_BIND_SERVICE)
- ✅ Runs on Debian slim image to minimize attack surface
- ✅ Persists node keys to prevent identity reset
- ⚠️ SOCKS5 proxy is not authenticated by default - restrict network access accordingly

## Building Locally

```bash
# Build the image
docker build -t lokinet-proxy:local .

# Run with Docker Compose
docker-compose up -d
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If this Docker image saved you time or helped you deploy a Lokinet node easily, consider supporting the development:

See [DONATE.md](DONATE.md) for donation options and crypto addresses.

## References

- [Lokinet Official Website](https://lokinet.io/)
- [Oxen Project](https://oxen.io/)
- [Lokinet GitHub Repository](https://github.com/oxen-io/lokinet)
- [Dante SOCKS Server](https://www.inet.no/dante/)

## Contributing

Contributions are welcome! Feel free to submit issues and pull requests.

---

**Privacy First** - Route your traffic through a decentralized network with Lokinet Proxy.
