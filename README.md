# Reflection for qBittorrent 5.x

A bridge that makes qBittorrent appear as a Transmission client. Use Transmission-compatible apps like [Truing](https://github.com/ddjohn/truing), Transmission Remote GUI, or any other Transmission RPC client to manage your qBittorrent instance.

This fork is patched to work with **qBittorrent 5.x** and is **not backwards compatible** with qBittorrent 4.x.

## Quick Start

```bash
docker pull jaap14/reflection:latest
docker run -d --name reflection \
  jaap14/reflection:latest \
  -r http://your-qbittorrent:8080/ -p 9091
```

Then point your Transmission client to `http://your-server:9091/transmission/rpc`

## Docker Compose

```yaml
version: "2.1"
services:
  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent:latest
    container_name: qbittorrent
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/Los_Angeles
      - WEBUI_PORT=8080
    volumes:
      - /path/to/config:/config
      - /path/to/downloads:/downloads
    ports:
      - 8080:8080
      - 6881:6881
      - 6881:6881/udp
    networks:
      - torrents
    restart: unless-stopped

  reflection:
    image: jaap14/reflection:latest
    container_name: reflection
    command: ["-r", "http://qbittorrent:8080/", "-p", "9091"]
    ports:
      - 9091:9091
    networks:
      - torrents
    depends_on:
      - qbittorrent
    restart: unless-stopped

networks:
  torrents:
    name: torrents
```

## qBittorrent WebUI Configuration

For Reflection to connect, configure qBittorrent WebUI settings:

1. **Settings → WebUI → IP Filtering**
   - Add your Docker network to the whitelist (e.g., `172.16.0.0/12`, `192.168.0.0/16`)
   - Or disable "Enable Host header validation"

2. **Authentication** (optional)
   - If using authentication, pass credentials via the qBittorrent URL:
   ```
   -r http://username:password@qbittorrent:8080/
   ```

## Command Line Options

| Flag | Default | Description |
|------|---------|-------------|
| `-r`, `-api-addr` | `http://localhost:8080/` | qBittorrent WebUI address |
| `-p`, `-port` | `9091` | Reflection listen port |
| `-v`, `-verbose` | `false` | Verbose logging |
| `-d`, `-debug` | `false` | Debug logging |
| `-sync` | `true` | Use sync endpoint for better performance |
| `-cache-timeout` | `15` | Cache timeout in seconds |

## Features

- **Full torrent management**: Start, stop, remove, add torrents
- **Labels**: qBittorrent categories and tags are mapped to Transmission labels
- **Trackers**: Real tracker URLs displayed (DHT/PeX/LSD pseudo-trackers filtered)
- **Statistics**: Upload/download speeds, ratios, peer counts
- **Multi-client support**: Run alongside actual Transmission instances

## qBittorrent 5.x API Changes

This fork includes the following fixes for qBittorrent 5.x compatibility:

| Endpoint | qBittorrent 4.x | qBittorrent 5.x |
|----------|-----------------|-----------------|
| Pause torrents | `torrents/pause` | `torrents/stop` |
| Resume torrents | `torrents/resume` | `torrents/start` |
| Delete torrents | GET | POST |
| Create category | GET | POST |

Additional fixes:
- Graceful handling of unknown fields (no crashes on new API fields)
- Proper label mapping from `category` + `tags` fields
- Filtered DHT/PeX/LSD pseudo-tracker entries

## Building from Source

```bash
# Clone
git clone https://github.com/jaap14/Reflection.git
cd Reflection

# Build multi-platform image
docker buildx create --name multibuilder --use
docker buildx build --platform linux/amd64,linux/arm64 -t jaap14/reflection:latest --push .
```

## Troubleshooting

**403 Forbidden from qBittorrent**
- Whitelist Docker networks in qBittorrent WebUI settings
- Disable "Enable Host header validation"

**Empty reply / Connection refused**
- Verify qBittorrent container name matches the `-r` URL
- Check both containers are on the same Docker network
- Test connectivity: `docker exec reflection wget -q -O- http://qbittorrent:8080/api/v2/app/version`

**Session load failed in client**
- Update to latest image: `docker pull jaap14/reflection:latest`
- Check logs: `docker logs reflection`

## Credits

Based on [h31/Reflection](https://github.com/h31/Reflection), updated for qBittorrent 5.x by [@jaap14](https://github.com/jaap14).

## License

MIT License - see [LICENSE.txt](LICENSE.txt)
