#!/bin/bash
set -eu

echo "[3/4] : initialize superchain and opcm"

if [ -z "${SUPERCHAIN_OPCM_ADDRESS}" ]; then
  cd ~/optimism/op-deployer/bin
  mkdir -p .op-deployer

  ./op-deployer bootstrap superchain \
    --l1-rpc-url "$L1_RPC_URL_DEPLOY" \
    --private-key "$FAUCET_PRIVATE_KEY" \
    --outfile ".op-deployer/superchain.json" \
    --superchain-proxy-admin-owner "$SUPERCHAIN_ADMIN_ADDRESS" \
    --protocol-versions-owner "$SUPERCHAIN_ADMIN_ADDRESS" \
    --guardian "$SUPERCHAIN_GUARDIAN_ADDRESS"
  cp .op-deployer/superchain.json /config/superchain.json

  SUPERCHAIN_CONFIG_PROXY=$(jq -r '.superchainConfigProxyAddress' .op-deployer/superchain.json)
  PROTOCOL_VERSIONS_PROXY=$(jq -r '.protocolVersionsProxyAddress' .op-deployer/superchain.json)
  SUPERCHAIN_PROXY_ADMIN=$(jq -r '.proxyAdminAddress' .op-deployer/superchain.json)

  ./op-deployer bootstrap implementations \
    --l1-rpc-url "$L1_RPC_URL_DEPLOY" \
    --private-key "$FAUCET_PRIVATE_KEY" \
    --mips-version "${MIPS_VERSION:-7}" \
    --outfile ".op-deployer/implementations.json" \
    --superchain-config-proxy "$SUPERCHAIN_CONFIG_PROXY" \
    --protocol-versions-proxy "$PROTOCOL_VERSIONS_PROXY" \
    --superchain-proxy-admin "$SUPERCHAIN_PROXY_ADMIN" \
    --upgrade-controller "$SUPERCHAIN_ADMIN_ADDRESS"
  cp .op-deployer/implementations.json /config/implementations.json

  export SUPERCHAIN_OPCM_ADDRESS=$(
    jq -r '
      .OPCM // .opcm // .OPContractsManagerProxy // .OPContractsManager // empty
    ' .op-deployer/implementations.json
  )
  echo "Deployed new OPCM address: $SUPERCHAIN_OPCM_ADDRESS"
else 
  echo "Using existing OPCM address: $SUPERCHAIN_OPCM_ADDRESS"
fi
