#!/bin/bash
set -eu

echo "[4/4] : generate config"

cd ~/optimism/op-deployer/bin

./op-deployer init \
  --l1-chain-id "$L1_CHAIN_ID" \
  --l2-chain-ids "$L2_CHAIN_ID" \
  --workdir .op-deployer

sed -i \
  -e "s/configType = \".*\"/configType = \"standard-overrides\"/" \
  -e "s/opcmAddress = \".*\"/opcmAddress = \"$SUPERCHAIN_OPCM_ADDRESS\"/" \
  -e "s/baseFeeVaultRecipient = \".*\"/baseFeeVaultRecipient = \"$ADMIN_ADDRESS\"/" \
  -e "s/l1FeeVaultRecipient = \".*\"/l1FeeVaultRecipient = \"$ADMIN_ADDRESS\"/" \
  -e "s/sequencerFeeVaultRecipient = \".*\"/sequencerFeeVaultRecipient = \"$ADMIN_ADDRESS\"/" \
  -e "s/l2ProxyAdminOwner = \".*\"/l2ProxyAdminOwner = \"$ADMIN_ADDRESS\"/" \
  -e "s/systemConfigOwner = \".*\"/systemConfigOwner = \"$ADMIN_ADDRESS\"/" \
  -e "s/unsafeBlockSigner = \".*\"/unsafeBlockSigner = \"$ADMIN_ADDRESS\"/" \
  -e "s/batcher = \".*\"/batcher = \"$BATCHER_ADDRESS\"/" \
  -e "s/proposer = \".*\"/proposer = \"$PROPOSER_ADDRESS\"/" \
  .op-deployer/intent.toml

cp .op-deployer/intent.toml /config/intent.toml

./op-deployer apply --workdir .op-deployer --l1-rpc-url $L1_RPC_URL --private-key $ADMIN_PRIVATE_KEY
./op-deployer inspect genesis --workdir .op-deployer $L2_CHAIN_ID > .op-deployer/genesis.json
./op-deployer inspect rollup --workdir .op-deployer $L2_CHAIN_ID > .op-deployer/rollup.json

cp .op-deployer/state.json /config/state.json
cp .op-deployer/genesis.json /config/genesis.json
cp .op-deployer/rollup.json /config/rollup.json

echo "[all process is done! check config files.]"