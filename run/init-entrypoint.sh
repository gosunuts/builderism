#!/bin/bash
set -eu

# Check environment variables
reqenv() {
  if [ -z "${!1:-}" ]; then
    echo "Error: environment variable '$1' is not set. check .env file!"
    exit 1
  fi
}
reqenv "CONFIG_DIR" 
reqenv "L1_RPC_URL"
reqenv "L1_RPC_KIND"
reqenv "L1_BEACON_URL"
reqenv "L2_CHAIN_ID"

if [ ! -z "${L2_SUPERCHAIN_NETWORK:-}" ]; then
  echo "init only running in custom chain, exiting on [$L2_SUPERCHAIN_NETWORK]..."
  exit 0
fi

exec /app/geth init \
  --datadir=/data \
  --state.scheme=path \
  --db.engine=pebble \
  /config/genesis.json