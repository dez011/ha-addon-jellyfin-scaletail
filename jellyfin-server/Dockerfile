# https://developers.home-assistant.io/docs/add-ons/configuration#add-on-dockerfile
FROM tailscale/tailscale:latest AS tailscale

FROM lscr.io/linuxserver/jellyfin:latest

RUN if command -v apk >/dev/null 2>&1; then \
	  apk add --no-cache jq; \
	elif command -v apt-get >/dev/null 2>&1; then \
	  apt-get update && apt-get install -y --no-install-recommends jq && rm -rf /var/lib/apt/lists/*; \
	else \
	  echo "No supported package manager found for jq install" >&2; \
	  exit 1; \
	fi

# Copy Tailscale binaries from the official image to avoid custom packaging.
COPY --from=tailscale /usr/local/bin/tailscale /usr/local/bin/tailscale
COPY --from=tailscale /usr/local/bin/tailscaled /usr/local/bin/tailscaled

COPY rootfs/usr/local/bin/start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

ENTRYPOINT ["/usr/local/bin/start.sh"]
