#!/bin/bash
set -eu

# .env
FAUCET_PRIVATE_KEY="$FAUCET_PRIVATE_KEY"
FAUCET_ADDRESS="$FAUCET_ADDRESS"

echo "[2/4] : faucet eth to environment accounts"

send_eth() {
  receiver_address="$1"
  amount_to_eth="$2"
  amount_to_send=$(cast to-wei $amount_to_eth)

  # if receiver has more eth than amount to send, no need to send
  receiver_balance=$(cast balance --rpc-url "$L1_RPC_URL" "$receiver_address")
  if [ "$(echo "$receiver_balance >= $amount_to_send" | bc)" -eq 1 ]; then
    echo "$receiver_address already has enough balance"
  else
    # if FAUCET_PRIVATE_KEY is not set, error
    if [ -z "$FAUCET_PRIVATE_KEY" ]; then
      echo "FAUCET_PRIVATE_KEY is not set"
      exit 1
    fi

    # if sender has less eth than amount to send, error
    sender_balance=$(cast balance --rpc-url "$L1_RPC_URL" "$FAUCET_ADDRESS")
    if [ "$(echo "$sender_balance < $amount_to_send" | bc)" -eq 1 ]; then
      echo "$FAUCET_ADDRESS does not have enough balance"
      exit 1
    fi

    # send eth
    cast send "$receiver_address" --priority-gas-price $PRIORITY_GAS_PRICE --value "$amount_to_send" --from "$FAUCET_ADDRESS" --private-key "$FAUCET_PRIVATE_KEY" --rpc-url "$L1_RPC_URL"
    echo "Sent $amount_to_eth eth to $receiver_address"
  fi
}

send_eth "$ADMIN_ADDRESS" $FAUCET_AMOUNT_ADMIN
send_eth "$BATCHER_ADDRESS" $FAUCET_AMOUNT_BATCHER
send_eth "$PROPOSER_ADDRESS" $FAUCET_AMOUNT_PROPOSER