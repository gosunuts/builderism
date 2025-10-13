#!/bin/bash
set -eu

RUN_MODE=${RUN_MODE:-"replica"}
if [ "$RUN_MODE" != "sequencer" ]; then
  echo "challenger only running in sequencer mode, exiting..."
  exit 0
fi

OP_CHALLENGER_L1_ETH_RPC=${L1_RPC_URL}
OP_CHALLENGER_L1_BEACON=${L1_BEACON_URL}
OP_CHALLENGER_GAME_FACTORY_ADDRESS=$(jq -r '.. | .DisputeGameFactoryProxy? // empty' /config/state.json)
OP_CHALLENGER_PRIVATE_KEY=$(grep "SUPERCHAIN_CHALLENGER_PRIVATE_KEY" /config/address.ini | cut -d'=' -f2)
OP_CHALLENGER_CANNON_L2_GENESIS=${OP_CHALLENGER_CANNON_L2_GENESIS:-"/config/genesis.json"}
OP_CHALLENGER_CANNON_ROLLUP_CONFIG=${OP_CHALLENGER_CANNON_ROLLUP_CONFIG:-"/config/rollup.json"}

exec /app/op-challenger run-trace \
  --trace-type permissioned,cannon \
  --l1-eth-rpc=$OP_CHALLENGER_L1_ETH_RPC \
  --l1-beacon=${OP_CHALLENGER_L1_BEACON} \
  --l2-eth-rpc=http://geth:8545 \
  --rollup-rpc=http://node:8547 \
  --datadir=/data \
  --game-factory-address $OP_CHALLENGER_GAME_FACTORY_ADDRESS \
  --private-key=${OP_CHALLENGER_PRIVATE_KEY} \
  --cannon-bin=/app/cannon \
  --cannon-rollup-config=$OP_CHALLENGER_CANNON_ROLLUP_CONFIG \
  --cannon-l2-genesis=$OP_CHALLENGER_CANNON_L2_GENESIS \
  --cannon-server=/app/op-program \
  --cannon-prestate=$OP_CHALLENGER_CANNON_PRESTATE