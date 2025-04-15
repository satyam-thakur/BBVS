#!/bin/env bash

source ./env_variables1.sh

export CHANNEL_NAME=mychannel
CC_NAME="voting8"
OUTPUT_FILE="caliper_style_throughput.csv"
TOTAL_TX=200
BATCH_SIZE=10
RAMP_UP_TIME=10

# Initialize results
echo "Batch,StartTime,EndTime,Duration,BatchThroughput,TotalThroughput,PendingTx" > $OUTPUT_FILE

# Timing functions
get_ns_time() { date +%s%N; }
ns_to_sec() { echo "$1" | awk '{printf "%.3f", $1/1000000000}'; }

# Throughput calculation engine
calculate_metrics() {
    local batch_num=$1
    local batch_start=$2
    local batch_end=$3
    local total_start=$4
    local completed_tx=$5
    local pending_tx=$6
    
    local batch_duration=$(ns_to_sec $((batch_end - batch_start)))
    local batch_tput=$(awk "BEGIN {printf \"%.2f\", $BATCH_SIZE/$batch_duration}")
    
    local total_duration=$(ns_to_sec $((batch_end - total_start)))
    local total_tput=$(awk "BEGIN {printf \"%.2f\", $completed_tx/$total_duration}")
    
    echo "$batch_num,$(ns_to_sec $batch_start),$(ns_to_sec $batch_end),$batch_duration,$batch_tput,$total_tput,$pending_tx" >> $OUTPUT_FILE
}

# Transaction submitter with async tracking
submit_transactions() {
    local tx_num=$1
    local start_ns=$(get_ns_time)
    
    docker exec cli peer chaincode invoke -o orderer.example.com:7050 \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses peer0.org1.example.com:7051 \
        --peerAddresses peer0.org2.example.com:9051 \
        --peerAddresses peer0.org3.example.com:11051 \
        -c '{"function": "CastVote","Args":["Trump","'$tx_num'"]}' \
        >/dev/null 2>&1 &
}

# Main execution flow
echo "Initializing Caliper-style throughput test..."
total_start=$(get_ns_time)
completed_tx=0
pending_queue=()

# Warm-up phase
echo "Ramping up for $RAMP_UP_TIME seconds..."
sleep $RAMP_UP_TIME

# Throughput test
for ((batch=0; batch*BATCH_SIZE < TOTAL_TX; batch++)); do
    batch_start=$(get_ns_time)
    
    # Submit batch
    for ((tx=0; tx<BATCH_SIZE && (batch*BATCH_SIZE+tx)<TOTAL_TX; tx++)); do
        submit_transactions $((batch*BATCH_SIZE+tx))
        pending_queue+=($!)
    done
    
    # Wait for batch completion
    for pid in "${pending_queue[@]}"; do
        wait $pid && ((completed_tx++)) || echo "TX failed: $pid"
    done
    pending_queue=()
    
    batch_end=$(get_ns_time)
    pending_tx=$((TOTAL_TX - completed_tx))
    
    # Calculate metrics
    calculate_metrics $batch $batch_start $batch_end $total_start $completed_tx $pending_tx
    
    # Progress monitoring
    echo "Batch $batch: Completed $completed_tx TX, Current TPS: $(awk "BEGIN {printf \"%.2f\", $BATCH_SIZE/$(ns_to_sec $((batch_end - batch_start)))}")"
done

# Final report
total_end=$(get_ns_time)
total_duration=$(ns_to_sec $((total_end - total_start)))
avg_tput=$(awk "BEGIN {printf \"%.2f\", $completed_tx/$total_duration}")

echo "=============================================="
echo " Throughput Test Results"
echo "=============================================="
echo "Total submitted TX:    $TOTAL_TX"
echo "Successfully completed: $completed_tx"
echo "Total duration:        ${total_duration}s"
echo "Average throughput:    ${avg_tput} TPS"
echo "Peak batch throughput: $(awk -F',' 'NR>1 {print $5}' $OUTPUT_FILE | sort -nr | head -1) TPS"
echo "Detailed metrics saved to: $OUTPUT_FILE"
