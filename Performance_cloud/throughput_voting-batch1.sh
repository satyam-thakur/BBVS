#!/bin/env bash

source ./env_variables1.sh

export CHANNEL_NAME=mychannel

CC_NAME="voting8"
OUTPUT_FILE="voting_throughput_batch.csv"
START_TX=1000
ITERATIONS=200
BATCH_SIZE=10

# Initialize results file
echo "batch_num,start_time,end_time,batch_duration,batch_throughput,overall_throughput,cpu_usage,memory_usage" > $OUTPUT_FILE

# Function to calculate time in seconds with nanosecond precision
get_timestamp() {
    date +%s.%N
}

CastVote() {
    local tx_num=$1
    docker exec cli peer chaincode invoke -o orderer.example.com:7050 \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses peer0.org1.example.com:7051 \
        --peerAddresses peer0.org2.example.com:9051 \
        --peerAddresses peer0.org3.example.com:11051 \
        -c '{"function": "CastVote","Args":["Trump","'$tx_num'"]}' \
        >/dev/null 2>&1
}

# Main execution
total_start=$(get_timestamp)
total_submitted=0
batch_num=0

for ((i=START_TX; i<START_TX+ITERATIONS; i+=BATCH_SIZE)); do
    batch_num=$((batch_num + 1))
    current_batch=$((ITERATIONS < i+BATCH_SIZE ? ITERATIONS-i : BATCH_SIZE))
    
    # Batch timing
    batch_start=$(get_timestamp)
    pids=()
    
    # Submit transactions in parallel
    for ((j=0; j<current_batch; j++)); do
        CastVote $((total_submitted + j)) &
        pids+=($!)
    done
    
    # Wait for batch completion
    for pid in "${pids[@]}"; do
        wait $pid || echo "Transaction failed: $pid"
    done
    
    batch_end=$(get_timestamp)
    total_submitted=$((total_submitted + current_batch))
    
    # Calculate batch metrics
    batch_duration=$(echo "$batch_end - $batch_start" | bc)
    batch_throughput=$(echo "scale=2; $current_batch / $batch_duration" | bc)
    
    # Calculate overall metrics
    total_duration=$(echo "$batch_end - $total_start" | bc)
    overall_throughput=$(echo "scale=2; $total_submitted / $total_duration" | bc)
    
    # Get system metrics
    current_usage=$(get_cpu_memory_usage)
    cpu_usage=$(echo "$current_usage" | awk '{print $1}')
    memory_usage=$(echo "$current_usage" | awk '{print $2}')
    
    # Log results
    echo "$batch_num,$batch_start,$batch_end,$batch_duration,$batch_throughput,$overall_throughput,$cpu_usage,$memory_usage" >> $OUTPUT_FILE
    
    # Progress monitoring
    echo "Batch $batch_num: $current_batch txns, Batch TPS: $batch_throughput, Overall TPS: $overall_throughput"
done

# Final report
total_end=$(get_timestamp)
total_duration=$(echo "$total_end - $total_start" | bc)
final_throughput=$(echo "scale=2; $total_submitted / $total_duration" | bc)

echo "=============================================="
echo " Final Report"
echo "=============================================="
echo "Total transactions submitted: $total_submitted"
echo "Total duration:          $(printf "%.2f" $total_duration) seconds"
echo "Average throughput:      $final_throughput TPS"
echo "Peak batch throughput:   $(awk -F',' 'NR>1 {print $5}' $OUTPUT_FILE | sort -nr | head -1) TPS"
echo "System resource peaks:"
echo "  CPU:  $(awk -F',' 'NR>1 {print $7}' $OUTPUT_FILE | sort -nr | head -1)%"
echo "  RAM:  $(awk -F',' 'NR>1 {print $8}' $OUTPUT_FILE | sort -nr | head -1)MB"
