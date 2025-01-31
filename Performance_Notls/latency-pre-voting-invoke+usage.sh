#!/bin/env bash

export CORE_PEER_TLS_ENABLED=false
export FABRIC_CFG_PATH=${PWD}/config/

export CHANNEL_NAME=mychannel1

CHANNEL_NAME="mychannel1"
CC_RUNTIME_LANGUAGE="golang"
VERSION="1"
CC_NAME="voting6"
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
VcmsVotingToken() {
    local tx_num=$1
    local start_time=$(date +%s%N)

    peer chaincode invoke -o localhost:7050 \
        -C $CHANNEL_NAME -n ${CC_NAME}  \
        --peerAddresses localhost:7051 \
        --peerAddresses localhost:9051 \
        -c '{"function": "VcmsVotingToken","Args":["'$tx_num'","digitalsignature"]}' 
        
        # >/dev/null

    local end_time=$(date +%s%N)
    local duration=$(( (end_time - start_time) / 1000000 ))
    sum_total_time=$((sum_total_time + duration))
    
    echo "$tx_num,$duration" \
    >> $OUTPUT_FILE
}

OUTPUT_FILE="pre-voting_Phase-latency&usage.csv"
sum_total_time=0
echo "tx_num, duration" >> $OUTPUT_FILE
start_tx=1
Num_of_tx=5

start_usage=($(get_cpu_memory_usage))
echo "start_usage CPU= ${start_usage[0]}% Memory= ${start_usage[1]}MB"
# set +x

for i in $(seq $start_tx $((Num_of_tx+start_tx)));
do
    VcmsVotingToken $i
done

# CPU Usage statistics
end_usage=($(get_cpu_memory_usage))
echo "end_usage CPU= ${end_usage[0]}% Memory= ${end_usage[1]}MB"

cpu_usage_diff=$(echo "${end_usage[0]} - ${start_usage[0]}" | bc)
memory_usage_diff=$(echo "${end_usage[1]} - ${start_usage[1]}" | bc)

echo "CPU Usage for $Num_of_tx transactions = $cpu_usage_diff%" >> $OUTPUT_FILE
echo "Memory Usage for $Num_of_tx transactions = $memory_usage_diff MB" >> $OUTPUT_FILE  

echo "Total number of transactions = $Num_of_tx" >> $OUTPUT_FILE
echo "average latency = $((sum_total_time / Num_of_tx)) ms" >> $OUTPUT_FILE
echo "Total latency = $sum_total_time ms" >> $OUTPUT_FILE

# set -x