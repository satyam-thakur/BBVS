#!/bin/env bash

source ./env_variables1.sh

export CHANNEL_NAME=mychannel
CC_NAME="voting8"

setGlobalsForPeer0Org1

# Function to invoke chaincode in the background
PostVoting() {
    local tx_num=$1
    peer chaincode invoke -o localhost:7050 \
        -C $CHANNEL_NAME -n ${CC_NAME}  \
        --peerAddresses localhost:7051 \
        --peerAddresses localhost:9051 \
        --peerAddresses localhost:11051 \
        --peerAddresses localhost:14051 \
        --peerAddresses localhost:15051 \
        --peerAddresses localhost:16051 \
        --peerAddresses localhost:17051 \
        --peerAddresses localhost:18051 \
        --peerAddresses localhost:19051 \
        -c '{"function": "PostVoting","Args":["'$tx_num'","voting_token"]}' \
        >/dev/null &
}

OUTPUT_FILE="throughput-postVoting-9validators.csv"
start_tx=9100
Num_of_tx=100

# Capture initial resource usage
start_usage=($(get_cpu_memory_usage))

# Record start time
start_time=$(date +%s%N)

# Start all transactions in the background
for i in $(seq $start_tx $((start_tx+Num_of_tx-1))); do
    PostVoting $i
done

# Wait for all background processes to complete
wait

# Record end time
end_time=$(date +%s%N)

# Calculate duration in seconds
duration_ns=$((end_time - start_time))
duration=$(echo "scale=2; $duration_ns / 1000000000" | bc)

# Calculate throughput
throughput=$(echo "scale=2; $Num_of_tx / $duration" | bc)

# Capture final resource usage
end_usage=($(get_cpu_memory_usage))
cpu_diff=$(echo "${end_usage[0]} - ${start_usage[0]}" | bc)
mem_diff=$(echo "${end_usage[1]} - ${start_usage[1]}" | bc)

# Write results to file
echo "Metric,Value" >> $OUTPUT_FILE
echo "Number of Transactions,$Num_of_tx" >> $OUTPUT_FILE
echo "Total Duration (s),$duration" >> $OUTPUT_FILE
echo "Throughput (TPS),$throughput" >> $OUTPUT_FILE
echo "CPU Usage Increase (%),$cpu_diff" >> $OUTPUT_FILE
echo "Memory Usage Increase (MB),$mem_diff" >> $OUTPUT_FILE

echo "Throughput evaluation complete. Results saved to $OUTPUT_FILE"