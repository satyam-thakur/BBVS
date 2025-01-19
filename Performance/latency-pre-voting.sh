#!/bin/bash

# pushd ../
export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export PEER0_ORG1_CA=${PWD}/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export PEER0_ORG2_CA=${PWD}/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/config/

# export PRIVATE_DATA_CONFIG=${PWD}/artifacts/private-data/collections_config.json

export CHANNEL_NAME=mychannel1

CHANNEL_NAME="mychannel1"
CC_RUNTIME_LANGUAGE="golang"
VERSION="1"
# CC_SRC_PATH="./artifacts/src/github.com/Ballot6"
CC_NAME="voting6"
setGlobalsForPeer0Org1() {
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}
setGlobalsForPeer0Org1

# popd
VcmsVotingToken() {
    local tx_num=$1
    local start_time=$(date +%s%N)

    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com \
        --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME}  \
        --peerAddresses localhost:7051 \
        --tlsRootCertFiles $PEER0_ORG1_CA \
        --peerAddresses localhost:9051 \
        --tlsRootCertFiles $PEER0_ORG2_CA   \
        -c '{"function": "VcmsVotingToken","Args":["'$tx_num'","digitalsignature"]}' \
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
        
        sleep 0.5  # Wait for 0.5 seconds before next query
    done

    local end_time=$(date +%s%N)
    local duration=$(( (end_time - start_time) / 1000000 ))
    sum_total_time=$((sum_total_time + duration))
    
    echo "$tx_num,$duration" >> $OUTPUT_FILE
}

OUTPUT_FILE="pre-voting_Phase-latency.csv"
sum_total_time=0
echo "tx_num, duration" >> $OUTPUT_FILE
start_tx=300
Num_of_tx=20

# set +x

for i in $(seq $start_tx $((Num_of_tx+start_tx)));
do
    VcmsVotingToken $i
done

echo "Total number of transactions = $Num_of_tx" >> $OUTPUT_FILE
echo "average latency = $((sum_total_time / Num_of_tx)) ms" >> $OUTPUT_FILE
echo "Total latency = $sum_total_time ms" >> $OUTPUT_FILE

# set -x