#!/bin/bash
set -eu

# check environment variables
reqenv() {
    if [ -z "${!1:-}" ]; then
        echo "Error: environment variable '$1' is not set. check .env file!"
        exit 1
    fi
}
reqenv "L1_RPC_URL"
reqenv "L1_CHAIN_ID"
reqenv "L2_CHAIN_ID"

echo "[1/3] : init environment variables"

export IMPL_SALT=$(openssl rand -hex 32)
export DEPLOYMENT_CONTEXT=$L2_CHAIN_ID
export FAUCET_ADDRESS=${FAUCET_ADDRESS:-""}
export FAUCET_PRIVATE_KEY=${FAUCET_PRIVATE_KEY:-""}

# overwrite l1 rpc address only for deploy
if [ ! -z "${L1_RPC_URL_DEPLOY:-}" ]; then
	export L1_RPC_URL=$L1_RPC_URL_DEPLOY
fi

# set priority gas price
if [ -z "${PRIORITY_GAS_PRICE:-}" ]; then
	export PRIORITY_GAS_PRICE=10000
fi
if [ -z "${FAUCET_AMOUNT_ADMIN:-}" ]; then
	export FAUCET_AMOUNT_ADMIN=0.5
fi
if [ -z "${FAUCET_AMOUNT_BATCHER:-}" ]; then
	export FAUCET_AMOUNT_BATCHER=0.2
fi
if [ -z "${FAUCET_AMOUNT_PROPOSER:-}" ]; then
	export FAUCET_AMOUNT_PROPOSER=0.1
fi

# generate l1 manager addresses
if [ -z "${ADMIN_ADDRESS:-}" ]; then
	wallet=$(cast wallet new)
	export ADMIN_ADDRESS=$(echo "$wallet" | awk '/Address/ { print $2 }')
	export ADMIN_PRIVATE_KEY=$(echo "$wallet" | awk '/Private key/ { print $3 }')
fi
if [ -z "${BATCHER_ADDRESS:-}" ]; then
	wallet=$(cast wallet new)
	export BATCHER_ADDRESS=$(echo "$wallet" | awk '/Address/ { print $2 }')
	export BATCHER_PRIVATE_KEY=$(echo "$wallet" | awk '/Private key/ { print $3 }')
fi
if [ -z "${PROPOSER_ADDRESS:-}" ]; then
	wallet=$(cast wallet new)
	export PROPOSER_ADDRESS=$(echo "$wallet" | awk '/Address/ { print $2 }')
	export PROPOSER_PRIVATE_KEY=$(echo "$wallet" | awk '/Private key/ { print $3 }')
fi

# save to file ( address.env )
sudo mkdir -p /config
env_file="/config/address.ini"
if [ -f "$env_file" ]; then
  sudo rm "$env_file"
fi
sudo tee "$env_file" > /dev/null <<EOF
ADMIN_ADDRESS=$ADMIN_ADDRESS
ADMIN_PRIVATE_KEY=$ADMIN_PRIVATE_KEY
BATCHER_ADDRESS=$BATCHER_ADDRESS
BATCHER_PRIVATE_KEY=$BATCHER_PRIVATE_KEY
PROPOSER_ADDRESS=$PROPOSER_ADDRESS
PROPOSER_PRIVATE_KEY=$PROPOSER_PRIVATE_KEY
EOF