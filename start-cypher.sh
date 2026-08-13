#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

DATADIR="chaindbname"

SNAPSHOT="chaindata0-328364.tar.zst"
URL="https://github.com/CypherTroopers/TarFile/releases/download/328364"

MARKER="$SCRIPT_DIR/$DATADIR/.initialized"

# ============================================================
# First-time initialization
# ============================================================

if [ ! -f "$MARKER" ]; then

  echo "============================================================"
  echo " First startup detected"
  echo " Initializing Cypher database..."
  echo "============================================================"

  mkdir -p "$DATADIR"

  echo
  echo "[1/5] Initializing genesis..."

  ./build/bin/cypher \
    --datadir "$DATADIR" \
    init ./genesis.json

  echo
  echo "[2/5] Removing initialized empty chaindata..."

  rm -rf "$DATADIR/cypher/chaindata"

  mkdir -p "$DATADIR/cypher"
  cd "$SCRIPT_DIR/$DATADIR/cypher"

  echo
  echo "[3/5] Downloading snapshot..."

  wget -O "$SNAPSHOT" "$URL/$SNAPSHOT"
  wget -O "$SNAPSHOT.sha256" "$URL/$SNAPSHOT.sha256"

  echo
  echo "[4/5] Verifying snapshot..."

  sha256sum -c "$SNAPSHOT.sha256"

  echo
  echo "[5/5] Extracting snapshot..."

  tar -I zstd -xvf "$SNAPSHOT"

  cd "$SCRIPT_DIR"

  # Initialization completed successfully
  touch "$MARKER"

  echo
  echo "============================================================"
  echo " Initial setup completed successfully."
  echo " Future executions will skip initialization."
  echo "============================================================"
  echo

else

  echo "============================================================"
  echo " Existing initialization detected"
  echo " Starting Cypher without database initialization..."
  echo "============================================================"
  echo

fi


# ============================================================
# Start Cypher
# ============================================================

PUBLIC_IP="$(curl -4fsS https://ifconfig.io/ip)"

echo "Public IP : $PUBLIC_IP"
echo "Data dir  : $DATADIR"
echo
echo "Starting Cypher..."
echo

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
