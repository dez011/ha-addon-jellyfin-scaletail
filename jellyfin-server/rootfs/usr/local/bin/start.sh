#!/usr/bin/env bash
set -euo pipefail

OPTIONS_FILE="/data/options.json"
TS_SOCKET="/var/run/tailscale/tailscaled.sock"
TS_STATE_DIR="/data/tailscale"
TS_STATE_FILE="${TS_STATE_DIR}/tailscaled.state"

mkdir -p "${TS_STATE_DIR}" /var/run/tailscale

SCALETAIL_ENABLED="false"
SCALETAIL_HOSTNAME="st-jellyfin"
SCALETAIL_AUTH_KEY=""
SCALETAIL_ENABLE_DNS="false"
SCALETAIL_DNS_SERVER="9.9.9.9"
SCALETAIL_ACCEPT_DNS="false"

if [[ -f "${OPTIONS_FILE}" ]]; then
  SCALETAIL_ENABLED="$(jq -r '.scaletail_enabled // false' "${OPTIONS_FILE}")"
  SCALETAIL_HOSTNAME="$(jq -r '.scaletail_hostname // "st-jellyfin"' "${OPTIONS_FILE}")"
  SCALETAIL_AUTH_KEY="$(jq -r '.scaletail_auth_key // ""' "${OPTIONS_FILE}")"
  SCALETAIL_ENABLE_DNS="$(jq -r '.scaletail_enable_dns // false' "${OPTIONS_FILE}")"
  SCALETAIL_DNS_SERVER="$(jq -r '.scaletail_dns_server // "9.9.9.9"' "${OPTIONS_FILE}")"
  SCALETAIL_ACCEPT_DNS="$(jq -r '.scaletail_accept_dns // false' "${OPTIONS_FILE}")"
fi

if [[ "${SCALETAIL_ENABLED}" == "true" ]]; then
  if [[ "${SCALETAIL_ENABLE_DNS}" == "true" && -n "${SCALETAIL_DNS_SERVER}" ]]; then
    echo "[scaletail] Using DNS server ${SCALETAIL_DNS_SERVER}"
    printf 'nameserver %s\n' "${SCALETAIL_DNS_SERVER}" > /etc/resolv.conf
  fi

  echo "[scaletail] Starting tailscaled"
  /usr/local/bin/tailscaled \
    --socket="${TS_SOCKET}" \
    --state="${TS_STATE_FILE}" \
    --tun=userspace-networking &

  for _ in $(seq 1 30); do
    if /usr/local/bin/tailscale --socket="${TS_SOCKET}" status >/dev/null 2>&1; then
      break
    fi
    sleep 1
  done

  TS_UP_ARGS=(
    --socket="${TS_SOCKET}"
    up
    --hostname="${SCALETAIL_HOSTNAME}"
    --accept-dns="${SCALETAIL_ACCEPT_DNS}"
    --reset
  )

  if [[ -n "${SCALETAIL_AUTH_KEY}" ]]; then
    TS_UP_ARGS+=(--authkey="${SCALETAIL_AUTH_KEY}")
  fi

  /usr/local/bin/tailscale "${TS_UP_ARGS[@]}"

  /usr/local/bin/tailscale \
    --socket="${TS_SOCKET}" \
    serve \
    --https=443 \
    http://127.0.0.1:8096

  echo "[scaletail] Tailnet URL should be available at https://${SCALETAIL_HOSTNAME}"
else
  echo "[scaletail] Disabled; starting Jellyfin without Tailscale"
fi

exec /init



