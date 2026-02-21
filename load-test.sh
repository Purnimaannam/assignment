#!/bin/bash

# Load testing script for Wallet API
# Usage: ./load-test.sh [num_requests] [num_concurrent]

NUM_REQUESTS=${1:-100}
NUM_CONCURRENT=${2:-10}
BASE_URL="http://localhost:8080/api/v1"

echo "=========================================="
echo "Wallet API - Load Testing"
echo "=========================================="
echo "Base URL: $BASE_URL"
echo "Total Requests: $NUM_REQUESTS"
echo "Concurrent: $NUM_CONCURRENT"
echo ""

# Create a wallet for testing
WALLET_ID=$(uuidgen)
echo "Creating test wallet: $WALLET_ID"

curl -s -X POST "$BASE_URL/wallet" \
    -H "Content-Type: application/json" \
    -d "{
        \"walletId\": \"$WALLET_ID\",
        \"operationType\": \"DEPOSIT\",
        \"amount\": 10000.00
    }" | jq .

echo ""
echo "Starting load test..."
echo ""

# Run load test
START_TIME=$(date +%s)

for i in $(seq 1 $NUM_REQUESTS); do
    AMOUNT=$((RANDOM % 100 + 1))
    OPERATION=$([ $((RANDOM % 2)) -eq 0 ] && echo "DEPOSIT" || echo "WITHDRAW")
    
    (
        curl -s -X POST "$BASE_URL/wallet" \
            -H "Content-Type: application/json" \
            -d "{
                \"walletId\": \"$WALLET_ID\",
                \"operationType\": \"$OPERATION\",
                \"amount\": $AMOUNT.00
            }" > /dev/null
        echo "Request $i: $OPERATION $AMOUNT" >&2
    ) &
    
    # Control concurrency
    if (( i % NUM_CONCURRENT == 0 )); then
        wait
    fi
done

wait

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""
echo "Load test completed in ${DURATION} seconds"
echo ""

# Get final balance
echo "Final wallet balance:"
curl -s -X GET "$BASE_URL/wallets/$WALLET_ID" | jq .

echo ""
echo "=========================================="
