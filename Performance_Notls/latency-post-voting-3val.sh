#!/bin/bash

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

# popd
PostVoting() {
    local tx_num=$1
    local start_time=$(date +%s%N)

   peer chaincode invoke -o localhost:7050 \
        -C $CHANNEL_NAME -n ${CC_NAME}  \
        --peerAddresses localhost:7051 \
        --peerAddresses localhost:9051 \
        --peerAddresses localhost:11051 \
        -c '{"function": "PostVoting","Args":["'$tx_num'","digitalsignature"]}' \
        >/dev/null  
        #2>&1

    # local query_result="Error"
    # while [[ $query_result == *"Error"* ]]; do
    #     query_result=$(peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} \
    #         -c '{"function": "GetVotingTokenRecord","Args":["'$tx_num'"]}' )
    #         #2>&1)
    # done
    
    local query_result=""
    local timeout=60  # 60 seconds timeout
    local query_start_time=$(date +%s)
    
    while true; do
        query_result=$(peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} \
            -c '{"function": "QueryPostVoting","Args":["'$tx_num'"]}' 2>&1)
        
        echo "$query_result"

        if [[ $query_result != *"Error"* ]] && [[ $query_result != "" ]]; then
            break
        fi
        
        local current_time=$(date +%s)
        if (( current_time - query_start_time > timeout )); then
            echo "Query timed out after $timeout seconds for transaction $tx_num" >&2
            return 1
        fi
        
        sleep 0.02  # Wait for 0.5 seconds before next query
    done

    local end_time=$(date +%s%N)
    local duration=$(( (end_time - start_time) / 1000000 ))
    sum_total_time=$((sum_total_time + duration))
    
    echo "$tx_num,$duration" >> $OUTPUT_FILE
}

OUTPUT_FILE="latency-post-voting-3val.csv"
sum_total_time=0
echo "tx_num, duration" >> $OUTPUT_FILE
start_tx=1
Num_of_tx=1000
# start_tx=100000000
# Num_of_tx=10
# set +x

for i in $(seq $start_tx $((Num_of_tx+start_tx)));
do
    PostVoting $i
done

echo "Total number of transactions = $Num_of_tx" >> $OUTPUT_FILE
echo "average latency = $((sum_total_time / Num_of_tx)) ms" >> $OUTPUT_FILE
echo "Total latency = $sum_total_time ms" >> $OUTPUT_FILE

# set -x