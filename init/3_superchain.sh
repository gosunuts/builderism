#!/bin/bash
set -eu

echo "[3/4] : initialize superchain and implements opcm"

cd ~/optimism/op-deployer/bin

if [ ! -f "/config/superchain.json" ]; then
  echo "Deploy new OPCM address"

  if [ -z "${SUPERCHAIN_ADMIN_ADDRESS:-}" ]; then
    wallet=$(cast wallet new)
    export SUPERCHAIN_ADMIN_ADDRESS=$(echo "$wallet" | awk '/Address/ { print $2 }')
    export SUPERCHAIN_ADMIN_PRIVATE_KEY=$(echo "$wallet" | awk '/Private key/ { print $3 }')
  fi
  if [ -z "${SUPERCHAIN_GUARDIAN_ADDRESS:-}" ]; then
    wallet=$(cast wallet new)
    export SUPERCHAIN_GUARDIAN_ADDRESS=$(echo "$wallet" | awk '/Address/ { print $2 }')
    export SUPERCHAIN_GUARDIAN_PRIVATE_KEY=$(echo "$wallet" | awk '/Private key/ { print $3 }')
  fi

  ./op-deployer bootstrap superchain \
    --l1-rpc-url "$L1_RPC_URL_DEPLOY" \
    --private-key "$FAUCET_PRIVATE_KEY" \
    --outfile "/config/superchain.json" \
    --superchain-proxy-admin-owner "$SUPERCHAIN_ADMIN_ADDRESS" \
    --protocol-versions-owner "$SUPERCHAIN_ADMIN_ADDRESS" \
    --guardian "$SUPERCHAIN_GUARDIAN_ADDRESS"
fi

SUPERCHAIN_CONFIG_PROXY=$(jq -r '.superchainConfigProxyAddress' /config/superchain.json)
PROTOCOL_VERSIONS_PROXY=$(jq -r '.protocolVersionsProxyAddress' /config/superchain.json)
SUPERCHAIN_PROXY_ADMIN=$(jq -r '.proxyAdminAddress' /config/superchain.json)

./op-deployer bootstrap implementations \
  --l1-rpc-url "$L1_RPC_URL_DEPLOY" \
  --private-key "$FAUCET_PRIVATE_KEY" \
  --mips-version "${MIPS_VERSION:-7}" \
  --outfile "/config/implementations.json" \
  --superchain-config-proxy "$SUPERCHAIN_CONFIG_PROXY" \
  --protocol-versions-proxy "$PROTOCOL_VERSIONS_PROXY" \
  --superchain-proxy-admin "$SUPERCHAIN_PROXY_ADMIN" \
  --upgrade-controller "$SUPERCHAIN_ADMIN_ADDRESS" \
  --challenger "$CHALLENGER_ADDRESS"


