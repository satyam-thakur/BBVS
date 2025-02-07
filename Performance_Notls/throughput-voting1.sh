#!/bin/env bash

export CORE_PEER_TLS_ENABLED=false
export FABRIC_CFG_PATH=${PWD}/config/

export CHANNEL_NAME=mychannel

CHANNEL_NAME="mychannel"
CC_RUNTIME_LANGUAGE="golang"
VERSION="1"
CC_NAME="voting8"
setGlobalsForPeer0Org1() {
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}
setGlobalsForPeer0Org1

get_cpu_memory_usage() {
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    memory_usage=$(free -m | awk '/Mem:/ {print $3}')
    echo "$cpu_usage $memory_usage"
}

CastVote() {
    local tx_num=$1
    echo "Casting vote for transaction $tx_num" >&2
    peer chaincode invoke -o localhost:7050 \
        -C $CHANNEL_NAME -n ${CC_NAME}  \
        --peerAddresses localhost:7051 \
        --peerAddresses localhost:9051 \
        -c '{"function": "CastVote","Args":["Trump","'$tx_num'"]}' \
        >/dev/null 2>&1 &
}

OUTPUT_FILE="voting_Phase_throughput_and_usage.csv"
echo "time,transactions,cpu_usage,memory_usage" >> $OUTPUT_FILE

start_tx=0
Num_of_tx=5  # Total number of transactions
batch_size=10  # Transactions per second

start_time=$(date +%s)
start_usage=$(get_cpu_memory_usage)
start_cpu=$(echo $start_usage | awk '{print $1}')
start_memory=$(echo $start_usage | awk '{print $2}')

echo "start_usage CPU= ${start_cpu}% Memory= ${start_memory}MB"
echo "Running for $Num_of_tx transactions in background"

for ((i=start_tx; i<start_tx+Num_of_tx; i+=batch_size)); do
    batch_start=$(date +%s%N)
    
    for ((j=i; j<i+batch_size && j<start_tx+Num_of_tx; j++)); do
        CastVote $j
    done
    
    wait  # Wait for all background processes to finish
    
    batch_end=$(date +%s%N)
    batch_duration=$((batch_end - batch_start))
    
    # If batch completed in less than a second, wait for the remainder
    if ((batch_duration < 1000000000)); then
        sleep_duration=$(bc <<< "scale=9; (1000000000 - $batch_duration) / 1000000000")
        sleep $sleep_duration
    fi
    
    current_time=$(($(date +%s) - start_time))
    current_usage=$(get_cpu_memory_usage)
    current_cpu=$(echo $current_usage | awk '{print $1}')
    current_memory=$(echo $current_usage | awk '{print $2}')
    
    echo "$current_time,$batch_size,$current_cpu,$current_memory" >> $OUTPUT_FILE
done

end_time=$(date +%s)
end_usage=$(get_cpu_memory_usage)
end_cpu=$(echo $end_usage | awk '{print $1}')
end_memory=$(echo $end_usage | awk '{print $2}')

total_duration=$((end_time - start_time))
avg_throughput=$(bc <<< "scale=2; $Num_of_tx / $total_duration")
cpu_diff=$(bc <<< "$end_cpu - $start_cpu")
memory_diff=$(bc <<< "$end_memory - $start_memory")

echo "Total transactions: $Num_of_tx" >> $OUTPUT_FILE
echo "Total duration: $total_duration seconds" >> $OUTPUT_FILE
echo "Average throughput: $avg_throughput TPS" >> $OUTPUT_FILE
echo "CPU usage difference: $cpu_diff%" >> $OUTPUT_FILE
echo "Memory usage difference: $memory_diff MB" >> $OUTPUT_FILE

echo "end_usage CPU= ${end_cpu}% Memory= ${end_memory}MB"
