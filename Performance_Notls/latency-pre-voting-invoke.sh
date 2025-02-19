#!/bin/env bash

source ./env_variables1.sh

export CHANNEL_NAME=mychannel1
# CHANNEL_NAME="mychannel1"
# CC_RUNTIME_LANGUAGE="golang"
# VERSION="1"
CC_NAME="voting6"

setGlobalsForPeer0Org1
VcmsVotingToken() {
    local tx_num=$1
    local start_time=$(date +%s%N)

    peer chaincode invoke -o localhost:7050 \
        -C $CHANNEL_NAME -n ${CC_NAME}  \
        --peerAddresses localhost:7051 \
        --peerAddresses localhost:9051 \
        --peerAddresses localhost:11051 \
        -c '{"function": "VcmsVotingToken","Args":["'$tx_num'","digitalsignature"]}'    
        # >/dev/null

    local end_time=$(date +%s%N)
    local duration=$(( (end_time - start_time) / 1000000 ))
    sum_total_time=$((sum_total_time + duration))
    
    echo "$tx_num,$duration" >> $OUTPUT_FILE
}

OUTPUT_FILE="Pre-voting-latency-Validators.csv"
sum_total_time=0
echo "tx_num, duration" >> $OUTPUT_FILE
# echo "Tx Block Size" >> tx_response.txt

start_tx=100700
Num_of_tx=50

start_usage=($(get_cpu_memory_usage))
echo "start_usage CPU= ${start_usage[0]}% Memory= ${start_usage[1]}MB"

# set +x

start_time=$(date +%s%N)

#'''+++++++++++++++++'''
for i in $(seq $start_tx $((Num_of_tx+start_tx-1)));
do
    VcmsVotingToken $i
done
#'''+++++++++++++++++'''

end_time=$(date +%s%N)
echo "Batch Tx. Duration: $(( (end_time - start_time) / 1000000 )) ms" >> $OUTPUT_FILE

#+++++++++++++++++++++++++++++++++++++++++++
end_usage=($(get_cpu_memory_usage))
echo "end_usage CPU= ${end_usage[0]}% Memory= ${end_usage[1]}MB"
cpu_usage_diff=$(echo "${end_usage[0]} - ${start_usage[0]}" | bc)
memory_usage_diff=$(echo "${end_usage[1]} - ${start_usage[1]}" | bc)
echo "CPU Usage for $Num_of_tx transactions = $cpu_usage_diff%" >> $OUTPUT_FILE
echo "Memory Usage for $Num_of_tx transactions = $memory_usage_diff MB" >> $OUTPUT_FILE  
#+++++++++++++++++++++++++++++++++++++++++++

echo "Total number of transactions = $Num_of_tx" >> $OUTPUT_FILE
echo "average latency = $((sum_total_time / Num_of_tx)) ms" >> $OUTPUT_FILE
echo "Total latency = $sum_total_time ms" >> $OUTPUT_FILE

# set -x
