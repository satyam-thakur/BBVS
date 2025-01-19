#!/bin/bash

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export PEER0_ORG1_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export PEER0_ORG2_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/artifacts/channel/config/

export CHANNEL_NAME=mychannel1

CHANNEL_NAME="mychannel1"
CC_RUNTIME_LANGUAGE="golang"
VERSION="1"
CC_SRC_PATH="./artifacts/src/github.com/Ballot6"
CC_NAME="voting6"

setGlobalsForPeer0Org1() {
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

setGlobalsForPeer0Org1

OUTPUT_FILE="transaction_latency-2.csv"

# Function to invoke transaction and calculate latency
invoke_transaction() {
    local tx_num=$1
    local start_time=$(date +%s.%N)

    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com \
        --tls true \
        --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n $CC_NAME \
        --peerAddresses localhost:7051 \
        --tlsRootCertFiles $PEER0_ORG1_CA \
        --peerAddresses localhost:9051 \
        --tlsRootCertFiles $PEER0_ORG2_CA \
        -c '{"function": "VcmsVotingToken","Args":["'$tx_num'","digitalsignature"]}' # &> /dev/null

    local end_time=$(date +%s.%N)
    local latency=$(echo "$end_time - $start_time" | bc)
    latency=$(echo "$latency * 1000" | bc) # Convert to milliseconds

    echo "$tx_num,$latency,$(date +'%Y-%m-%d %H:%M:%S')" >> $OUTPUT_FILE
    echo "Transaction $tx_num: Latency = $latency ms"
}

# Main execution
echo "Transaction Number,Latency (ms),Timestamp" > $OUTPUT_FILE

for i in $(seq 1 50); do
    invoke_transaction $i
done

echo "Transaction latency data has been written to $OUTPUT_FILE"
