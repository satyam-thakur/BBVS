#!/bin/bash

source ./env_variables1.sh

export CHANNEL_NAME=mychannel1
CC_NAME="voting6"

setGlobalsForPeer0Org1

# Voting function for both latency and throughput test.
VcmsVotingToken() {
    local tx_num=$1
    local start_time=$(date +%s%N)

    # Invoke the chaincode in background and wait for completion.
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
        -c '{"function": "VcmsVotingToken","Args":["'"$tx_num"'","digitalsignature"]}' \
        >/dev/null &
    wait $!

    local end_time1=$(date +%s%N)
    local duration1=$(( end_time1 - start_time ))
    # Accumulate total commit time (in nanoseconds)
    total_commit=$(( total_commit + duration1 ))

    local query_result=""
    local timeout=60
    local query_start_time=$(date +%s)
    
    # Query until a valid result is obtained.
    while true; do
        query_result=$(peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} \
            -c '{"function": "GetVotingTokenRecord","Args":["'$tx_num'"]}' 2>&1)
        
        echo "$query_result"

        if [[ $query_result != *"Error"* ]] && [[ $query_result != "" ]]; then
            break
        fi
        
        local current_time=$(date +%s)
        if (( current_time - query_start_time > timeout )); then
            echo "Query timed out after $timeout seconds for transaction $tx_num" >&2
            return 1
        fi
        sleep 0.5
    done

    local end_time=$(date +%s%N)
    local duration=$(( end_time - start_time ))
    sum_total_time=$(( sum_total_time + duration ))
    
    # Output the transaction number and its total latency (in nanoseconds)
    echo "$tx_num,$duration"
}

OUTPUT_FILE="Pre-voting-metrics-9Validators.csv"

echo "E-voting Network Metric, Calculation" >> $OUTPUT_FILE

    # Global accumulators for latency and commit timing.
    sum_total_time=0
    total_commit=0

    start_tx=199100
    Num_of_tx=50

    start_usage=($(get_cpu_memory_usage))
    echo "start_usage CPU= ${start_usage[0]}% Memory= ${start_usage[1]}MB"

#+++++++++++++++++++++++++++++++++++++++++++
LatencyMetric() {
    for i in $(seq $start_tx $((Num_of_tx+start_tx-1))); do
        VcmsVotingToken $i
    done
}
LatencyMetric

    # Convert total latency from nanoseconds to milliseconds.
    sum_total_time=$(( sum_total_time / 1000000 ))
    echo "Time: $(date)" >> $OUTPUT_FILE
    echo "Total number of transactions = $Num_of_tx" >> $OUTPUT_FILE
    echo "Batch Tx. Duration: $sum_total_time ms" >> $OUTPUT_FILE
    echo "Average Latency = $(( sum_total_time / Num_of_tx )) ms" >> $OUTPUT_FILE

    # Compute throughput as total transactions divided by the accumulated commit time (converted to seconds)
    echo "average throughput = $(( Num_of_tx / ( total_commit / 1000000000 ) )) Tps" >> $OUTPUT_FILE
    #+++++++++++++++++++++++++++++++++++++++++++
    end_usage=($(get_cpu_memory_usage))
    echo "end_usage CPU= ${end_usage[0]}% Memory= ${end_usage[1]}MB"
    cpu_usage_diff=$(echo "${end_usage[0]} - ${start_usage[0]}" | bc)
    memory_usage_diff=$(echo "${end_usage[1]} - ${start_usage[1]}" | bc)
    echo "CPU Usage for $Num_of_tx transactions = $cpu_usage_diff%" >> $OUTPUT_FILE
    echo "Memory Usage for $Num_of_tx transactions = $memory_usage_diff MB" >> $OUTPUT_FILE  

#+++++++++++++++++++++++++++++++++++++++++++

# Background voting function for throughput tests.
VcmsVotingTokenBackground() {
    local tx_num=$1
    peer chaincode invoke -o localhost:7050 \
        -C $CHANNEL_NAME -n ${CC_NAME}  \
        --peerAddresses localhost:7051 \
        --peerAddresses localhost:9051 \
        --peerAddresses localhost:11051 \
        -c '{"function": "VcmsVotingToken","Args":["'"$tx_num"'","digitalsignature"]}' \
        >/dev/null &
}

calculate_latency() {
    local num_tx=$1
    local output_file=$2
    local start_index=$3
    local sum_total_time=0

    echo "tx_num,duration" >> $output_file
    for i in $(seq $start_index $((start_index+num_tx-1))); do
        result=$(VcmsVotingToken $i)
        echo "$result" >> $output_file
        duration=$(echo $result | cut -d',' -f2)
        sum_total_time=$(( sum_total_time + duration ))
    done

    echo "Total number of transactions = $num_tx" >> $output_file
    echo "Average latency = $(( sum_total_time / num_tx )) ms" >> $output_file
    echo "Total latency = $sum_total_time ms" >> $output_file
}

calculate_throughput() {
    local num_tx=$1
    local output_file=$2
    local start_index=$3

    start_usage=($(get_cpu_memory_usage))
    start_time=$(date +%s%N)

    for i in $(seq $((start_index+10000)) $((start_index+num_tx))); do
        VcmsVotingTokenBackground $i
    done

    wait

    end_time=$(date +%s%N)
    duration_ns=$(( end_time - start_time ))
    duration=$(echo "scale=2; $duration_ns / 100000000" | bc)
    throughput=$(echo "scale=2; $num_tx / $duration" | bc)

    end_usage=($(get_cpu_memory_usage))
    cpu_diff=$(echo "${end_usage[0]} - ${start_usage[0]}" | bc)
    mem_diff=$(echo "${end_usage[1]} - ${start_usage[1]}" | bc)

    echo "Metric,Value for independent calculation" >> $output_file
    echo "Number of Transactions,$num_tx" >> $output_file
    echo "Total Duration (s),$duration" >> $output_file
    echo "Throughput (TPS),$throughput" >> $output_file
    echo "CPU Usage Increase (%),$cpu_diff" >> $output_file
    echo "Memory Usage Increase (MB),$mem_diff" >> $output_file
}

# Main execution for additional latency and throughput tests.
METRICS_OUTPUT=$OUTPUT_FILE
START_INDEX_LATENCY=1200000
NUM_OF_TX=20

# echo "Calculating Latency..."
# calculate_latency $NUM_OF_TX  $METRICS_OUTPUT $START_INDEX_LATENCY

# echo "Calculating Throughput..."
# calculate_throughput $NUM_OF_TX $METRICS_OUTPUT $START_INDEX_LATENCY

# echo "Evaluation complete. Results saved to $METRICS_OUTPUT"
