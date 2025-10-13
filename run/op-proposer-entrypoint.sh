#!/bin/bash
set -eu

RUN_MODE=${RUN_MODE:-"replica"}
if [ "$RUN_MODE" != "sequencer" ]; then
  echo "proposer only running in sequencer mode, exiting..."
  exit 0
fi

OP_PROPOSER_L1_ETH_RPC=${L1_RPC_URL}
OP_PROPOSER_GAME_FACTORY_ADDRESS=$(jq -r '.. | .DisputeGameFactoryProxy? // empty' /config/state.json)
OP_PROPOSER_PRIVATE_KEY=$(grep "PROPOSER_PRIVATE_KEY" /config/address.ini | cut -d'=' -f2)

echo ${OP_PROPOSER_GAME_FACTORY_ADDRESS}

exec /app/op-proposer \
  --l1-eth-rpc=${OP_PROPOSER_L1_ETH_RPC} \
  --rollup-rpc=http://node:8547 \
  --poll-interval=20s \
  --proposal-interval=4m \
  --rpc.port=8560 \
  --rpc.enable-admin \
  --game-factory-address=${OP_PROPOSER_GAME_FACTORY_ADDRESS} \
  --game-type=1 \
  --allow-non-finalized=false \
  --num-confirmations=1 \
  --resubmission-timeout=30s \
  --wait-node-sync=true \
  --private-key=${OP_PROPOSER_PRIVATE_KEY}