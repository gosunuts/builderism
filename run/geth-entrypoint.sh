#!/bin/bash
set -eu

RUN_MODE=${RUN_MODE:-"replica"}

ADDITIONAL_ARGS=""
if [ "$RUN_MODE" != "sequencer" ]; then
  if [ ! -z "${OP_GETH_SEQUENCER_HTTP:-}" ]; then
    ADDITIONAL_ARGS+=" --rollup.halt=major"
    ADDITIONAL_ARGS+=" --rollup.sequencerhttp=$OP_GETH_SEQUENCER_HTTP"
  fi
  if [ ! -z "${L2_SUPERCHAIN_NETWORK:-}" ]; then
    ADDITIONAL_ARGS+=" --op-network=$L2_SUPERCHAIN_NETWORK"
  fi
fi

exec /app/geth \
  --datadir=/data \
  --db.engine=pebble \
  --state.scheme=path \
  --networkid=${L2_CHAIN_ID} \
  --syncmode=full \
  --gcmode=full \
  --http \
  --http.vhosts="*" \
  --http.corsdomain="*" \
  --http.addr=0.0.0.0 \
  --http.port=8545 \
  --http.api=web3,debug,eth,txpool,net,engine,miner \
  --ws \
  --ws.addr=0.0.0.0 \
  --ws.port=8546 \
  --ws.origins="*" \
  --ws.api=web3,debug,eth,txpool,net,engine,miner \
  --authrpc.vhosts="*" \
  --authrpc.addr=0.0.0.0 \
  --authrpc.port=8551 \
  --authrpc.jwtsecret=/data/jwt.txt \
  --rollup.disabletxpoolgossip=true \
  $ADDITIONAL_ARGS