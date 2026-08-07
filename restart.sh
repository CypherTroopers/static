#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

DATADIR="chaindbname"

PUBLIC_IP="$(curl -4fsS https://ifconfig.io/ip)"

exec ./build/bin/cypher \
  --verbosity 4 \
  --rnetport 7100 \
  --syncmode full \
  --nat "extip:${PUBLIC_IP}" \
  --ws \
  --ws.addr 0.0.0.0 \
  --ws.port 8546 \
  --ws.origins "*" \
  --metrics \
  --http \
  --http.addr 0.0.0.0 \
  --http.port 8000 \
  --http.api eth,web3,net,txpool \
  --http.corsdomain "*" \
  --port 6000 \
  --datadir "$DATADIR" \
  --config static-nodes.toml \
  --networkid 16166 \
  --gcmode archive \
  console
