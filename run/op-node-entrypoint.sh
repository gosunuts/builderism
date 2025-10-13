#!/bin/bash
set -eu

RUN_MODE=${RUN_MODE:-"replica"}

OP_NODE_L1_ETH_RPC=${L1_RPC_URL}
OP_NODE_L1_BEACON=${L1_BEACON_URL}
ADDITIONAL_ARGS=""
if [ "$RUN_MODE" = "sequencer" ]; then
  SEQUENCER_PRIVATE_KEY=$(grep "SEQUENCER_PRIVATE_KEY" /config/address.ini | cut -d'=' -f2)
  ADDITIONAL_ARGS+=" \
    --rollup.config=/config/rollup.json \
    --sequencer.enabled \
    --sequencer.l1-confs=5 \
    --verifier.l1-confs=4 \
    --p2p.sequencer.key=${SEQUENCER_PRIVATE_KEY}"
else
  if [ ! -z "${OP_NODE_P2P_BOOTNODES:-}" ]; then
    ADDITIONAL_ARGS+=" --p2p.bootnodes=$OP_NODE_P2P_BOOTNODES"
  fi
  if [ ! -z "${L1_BEACON_FALLBACK_URL:-}" ]; then
    ADDITIONAL_ARGS+=" --l1.beacon-fallbacks=$L1_BEACON_FALLBACK_URL"
  fi
  if [ ! -z "${L2_SUPERCHAIN_NETWORK:-}" ]; then
    ADDITIONAL_ARGS+=" --network=$L2_SUPERCHAIN_NETWORK"
  else
    ROLLUP_CONFIG_PATH=${ROLLUP_CONFIG_PATH:-"/config"}
    ADDITIONAL_ARGS+=" --rollup.config=$ROLLUP_CONFIG_PATH/rollup.json"
  fi
fi

if [ ! -z "${ALT_DA_SERVER:-}" ]; then
  ADDITIONAL_ARGS+=" --altda.da-server=$ALT_DA_SERVER --altda.enabled"
fi

get_public_ip() {
  # Define a list of HTTP-based providers
  local PROVIDERS=(
    "http://ifconfig.me"
    "http://api.ipify.org"
    "http://ipecho.net/plain"
    "http://v4.ident.me"
  )
  # Iterate through the providers until an IP is found or the list is exhausted
  for provider in "${PROVIDERS[@]}"; do
    local IP
    IP=$(curl -s "$provider")
    # Check if IP contains a valid format (simple regex for an IPv4 address)
    if [[ $IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      echo "$IP"
      return 0
    fi
  done
  return 1
}

# public-facing P2P node, advertise public IP address
OP_NODE_P2P_ADVERTISE_IP=$(get_public_ip)
if [ ! -z "${OP_NODE_P2P_ADVERTISE_IP:-}" ]; then
  ADDITIONAL_ARGS="$ADDITIONAL_ARGS \
    --p2p.advertise.ip=$OP_NODE_P2P_ADVERTISE_IP"
fi

exec /app/op-node \
  --l1=${OP_NODE_L1_ETH_RPC} \
  --l1.beacon=${OP_NODE_L1_BEACON} \
  --l1.rpckind=${L1_RPC_KIND} \
  --l2=http://geth:8551 \
  --l2.jwt-secret=/data/jwt.txt \
  --rpc.addr=0.0.0.0 \
  --rpc.port=8547 \
  --rpc.enable-admin \
  --p2p.listen.ip=0.0.0.0 \
  --p2p.listen.tcp=9222 \
  --p2p.listen.udp=9222 \
  --sequencer.max-safe-lag=3600 \
  --verifier.l1-confs=4 \
  $ADDITIONAL_ARGS
