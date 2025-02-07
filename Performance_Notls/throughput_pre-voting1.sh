#!/bin/bash

# Environment Configuration
export CORE_PEER_TLS_ENABLED=false
export FABRIC_CFG_PATH=${PWD}/config/
export CHANNEL_NAME="mychannel1"
CC_NAME="voting6"

# Transaction Parameters
start_tx=801
Num_of_tx=100  # Total transactions for 1 second
batch_size=50   # Number of transactions per batch
OUTPUT_FILE="throughput_pre-voting1.csv"

# Initialize Output File
echo "tx_num,latency_ms" >> $OUTPUT_FILE

# Utility Function to Get CPU/Memory Usage
get_cpu_memory_usage() {
    read cpu memory <<< $(top -bn1 | awk '/Cpu/ {cpu=100-$8} /Mem/ {used=$3} END {print cpu" "used}')
    echo "${cpu} ${memory}"
}

# Function to Send a Transaction
VcmsVotingToken() {
    local tx_num=$1
    local start_time=$(date +%s%3N)  # Millisecond precision

    peer chaincode invoke -o localhost:7050 \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:7051 \
        --peerAddresses localhost:9051 \
        --peerAddresses localhost:11051 \
        -c '{"function": "VcmsVotingToken","Args":["'$tx_num'","digitalsignature"]}' >/dev/null 2>&1

    local end_time=$(date +%s%3N)
    local latency=$((end_time - start_time))
    echo "$tx_num,$latency" >> $OUTPUT_FILE
}

# Start Monitoring CPU and Memory Usage
start_usage=($(get_cpu_memory_usage))
echo "Start CPU: ${start_usage[0]}%, Start Memory: ${start_usage[1]}MB"

# Start Timer
start_time=$(date +%s%3N)

# Send Transactions in Batches
for ((i=start_tx; i<start_tx+Num_of_tx; i+=batch_size)); do
    for ((j=i; j<i+batch_size && j<start_tx+Num_of_tx; j++)); do
        VcmsVotingToken $j &
    done
    wait  # Wait for all transactions in the batch to complete
done

# End Timer
end_time=$(date +%s%3N)

# Calculate Total Duration and Throughput
total_duration=$((end_time - start_time))  # In milliseconds
tps=$(bc <<< "scale=2; $Num_of_tx / ($total_duration / 1000)")

# End Monitoring CPU and Memory Usage
end_usage=($(get_cpu_memory_usage))
cpu_diff=$(bc <<< "${end_usage[0]} - ${start_usage[0]}")
memory_diff=$(bc <<< "${end_usage[1]} - ${start_usage[1]}")

# Display Results
echo "==================== Throughput Test Results ===================="
echo "Total Transactions: $Num_of_tx"
echo "Total Duration: $((total_duration / 1000)) seconds"
echo "Average TPS: $tps"
echo "CPU Usage Change: ${cpu_diff}%"
echo "Memory Usage Change: ${memory_diff}MB"
echo "Detailed results saved in $OUTPUT_FILE"
