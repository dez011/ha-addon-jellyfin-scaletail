# Jellyfin Server Add-on

![Supports amd64 Architecture][amd64-shield]
![Supports aarch64 Architecture][aarch64-shield]

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg

This [Home Assistant](https://www.home-assistant.io/addons/) add-on installs the
[Jellyfin](https://jellyfin.org/) server.

Server is exposed on port `8096`, and must be accessed directly.

## Optional: ScaleTail / Tailscale Serve

This add-on can optionally start Tailscale Serve and expose Jellyfin on your
tailnet over HTTPS.

Configuration options:

- `scaletail_enabled`: Enable or disable Tailscale Serve integration.
- `scaletail_hostname`: Tailscale hostname (default: `st-jellyfin`).
- `scaletail_auth_key`: Tailscale auth key (paste your key in this field).
- `scaletail_enable_dns`: Override container DNS resolver with a custom server.
- `scaletail_dns_server`: DNS server used when DNS override is enabled (default: `9.9.9.9`).
- `scaletail_accept_dns`: Set Tailscale `--accept-dns` (enable this for MagicDNS).

When enabled, the add-on starts Tailscale in userspace mode and serves
`http://127.0.0.1:8096` on `https://<scaletail_hostname>` inside your tailnet.

Configuration and caches are stored on `share` (not in config), therefore
its data will not be deleted when add-on is uninstalled, and must be deleted
manually. This is intentional.
