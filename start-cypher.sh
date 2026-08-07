#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

DATADIR="chaindbname"
SNAPSHOT="chaindata0-328364.tar.zst"
URL="https://github.com/CypherTroopers/TarFile/releases/download/328364"

./build/bin/cypher \
  --datadir "$DATADIR" \
  init ./genesis.json

rm -rf "$DATADIR/cypher/chaindata"

cd "$SCRIPT_DIR/$DATADIR/cypher"

wget -O "$SNAPSHOT" "$URL/$SNAPSHOT"
wget -O "$SNAPSHOT.sha256" "$URL/$SNAPSHOT.sha256"

sha256sum -c "$SNAPSHOT.sha256"

tar -I zstd -xvf "$SNAPSHOT"

cd "$SCRIPT_DIR"

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
