#!/bin/bash

export CORE_PEER_TLS_ENABLED=false
export FABRIC_CFG_PATH=${PWD}/config/

export CHANNEL_NAME=mychannel

CHANNEL_NAME="mychannel"
CC_RUNTIME_LANGUAGE="golang"
VERSION="2"
CC_NAME="voting8"

setGlobalsForPeer0Org1() {
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}
setGlobalsForPeer0Org1

# popd
CastVote() {
    local tx_num=$1
    local start_time=$(date +%s%N)

   docker exec -it cli  peer chaincode invoke -o orderer.example.com:7050 \
        -C $CHANNEL_NAME -n ${CC_NAME}  \
        --peerAddresses peer0.org1.example.com:7051 \
        --peerAddresses peer0.org2.example.com:9051 \
        --peerAddresses peer0.org3.example.com:11051 \
        --peerAddresses peer0.org4.example.com:14051 \
        --peerAddresses peer0.org5.example.com:15051 \
        --peerAddresses peer0.org6.example.com:16051 \
        --peerAddresses peer0.org7.example.com:17051 \
        --peerAddresses peer0.org8.example.com:18051 \
        --peerAddresses peer0.org9.example.com:19051 \
        -c '{"function": "CastVote","Args":["Candidate_X","'$tx_num'"]}' \
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
            -c '{"function": "QueryCastVote","Args":["'$tx_num'"]}' 2>&1)
        
        echo "$query_result"

        if [[ $query_result != *"Error"* ]] && [[ $query_result != "" ]]; then
            break
        fi
        
        local current_time=$(date +%s)
        if (( current_time - query_start_time > timeout )); then
            echo "Query timed out after $timeout seconds for transaction $tx_num" >&2
            return 1
        fi
        
        sleep 0.05  # Wait for 0.5 seconds before next query
    done

    local end_time=$(date +%s%N)
    local duration=$(( (end_time - start_time) / 1000000 ))
    sum_total_time=$((sum_total_time + duration))
    
    echo "$tx_num,$duration" >> $OUTPUT_FILE
}

OUTPUT_FILE="latency-voting-9val.csv"
sum_total_time=0
echo "tx_num, duration" >> $OUTPUT_FILE
start_tx=10
Num_of_tx=2

# set +x

for i in $(seq $start_tx $((Num_of_tx+start_tx)));
do
    CastVote $i
done

echo "Total number of transactions = $Num_of_tx" >> $OUTPUT_FILE
echo "average latency = $((sum_total_time / Num_of_tx)) ms" >> $OUTPUT_FILE
echo "Total latency = $sum_total_time ms" >> $OUTPUT_FILE

# set -x