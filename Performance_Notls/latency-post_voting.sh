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

CastVote() {
    local tx_num=$1
    local start_time=$(date +%s%N)

    peer chaincode invoke -o localhost:7050 \
        -C $CHANNEL_NAME -n ${CC_NAME}  \
        --peerAddresses localhost:7051 \
        --peerAddresses localhost:9051 \
        --peerAddresses localhost:11051 \
        --peerAddresses localhost:14051 \
        --peerAddresses localhost:15051 \
        --peerAddresses localhost:16051 \
        --peerAddresses localhost:17051 \
        -c '{"function": "PostVoting","Args":["'$tx_num'","voting_token"]}' #2>&1
        
        # >/dev/null

    local end_time=$(date +%s%N)
    local duration=$(( (end_time - start_time) / 1000000 ))
    sum_total_time=$((sum_total_time + duration))
    
    echo "$tx_num,$duration" \
    >> $OUTPUT_FILE
}

OUTPUT_FILE="Post-voting_latency-7Validators.csv"
sum_total_time=0
echo "tx_num, duration" >> $OUTPUT_FILE
start_tx=1002
Num_of_tx=1000

# set +x

for i in $(seq $start_tx $((Num_of_tx+start_tx)));
do
    CastVote $i
done

echo "Total number of transactions = $Num_of_tx" >> $OUTPUT_FILE
echo "average latency = $((sum_total_time / Num_of_tx)) ms" >> $OUTPUT_FILE
echo "Total latency = $sum_total_time ms" >> $OUTPUT_FILE

# set -x