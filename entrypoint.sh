#!/bin/sh
set -e

# Config is generated at container start from environment variables.
# Required env: UUID, WS_PATH (e.g. /ray-xxxxxxxx). PORT is set by Render.
: "${UUID:?UUID env var is required}"
: "${WS_PATH:?WS_PATH env var is required}"
PORT="${PORT:-10000}"

mkdir -p /etc/xray
cat > /etc/xray/config.json <<EOF
{
  "log": { "loglevel": "warning" },
  "inbounds": [
    {
      "listen": "0.0.0.0",
      "port": ${PORT},
      "protocol": "vless",
      "settings": {
        "clients": [ { "id": "${UUID}" } ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": { "path": "${WS_PATH}" }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls", "quic"]
      }
    }
  ],
  "outbounds": [
    { "protocol": "freedom", "tag": "direct" },
    { "protocol": "blackhole", "tag": "block" }
  ]
}
EOF

exec /usr/local/bin/xray run -c /etc/xray/config.json
