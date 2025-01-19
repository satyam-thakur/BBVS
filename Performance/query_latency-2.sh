#!/bin/bash

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export PEER0_ORG1_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export PEER0_ORG2_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/artifacts/channel/config/

export PRIVATE_DATA_CONFIG=${PWD}/artifacts/private-data/collections_config.json

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

OUTPUT_FILE="transaction_metrics.csv"
# Function to invoke transaction and calculate metrics
invoke_transaction() {
    local tx_num=$1
    local start_time=$(date +%s.%N)
    local cpu_start=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')

    # Invoke the chaincode and capture the transaction ID
    local tx_id=$(peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com \
        --tls true \
        --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n $CC_NAME \
        --peerAddresses localhost:7051 \
        --tlsRootCertFiles $PEER0_ORG1_CA \
        --peerAddresses localhost:9051 \
        --tlsRootCertFiles $PEER0_ORG2_CA \
        -c '{"function": "VcmsVotingToken","Args":["'$tx_num'","digitalsignature"]}') 
        # --waitForEvent 2>&1 | grep "Chaincode invoke successful" | awk '{print $NF}')

    local status=$?
    local end_time=$(date +%s.%N)
    local cpu_end=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    
    local latency=$(echo "$end_time - $start_time" | bc)
    latency=$(echo "$latency * 1000" | bc) # Convert to milliseconds
    
    local cpu_util=$(echo "($cpu_end + $cpu_start) / 2" | bc)

    # # Verify transaction success
    # if [ -n "$tx_id" ]; then
    #     local verify_result=$(peer chaincode query -C $CHANNEL_NAME -n $CC_NAME -c '{"function":"GetBallot","Args":["'$tx_id'"]}')
    #     if [[ $verify_result == *"true"* ]]; then
    #         status=0 # Success
    #     else
    #         status=1 # Failed
    #     fi
    # else
    #     status=1 # Failed
    # fi
    
    if [ $status -eq 0 ]; then
        status='success'
    else
        status='failed'
    fi

    echo "$tx_num,$status,$latency,$cpu_util,$(date +'%Y-%m-%d %H:%M:%S')" >> $OUTPUT_FILE
    # echo "Transaction $tx_num: Success=$status, Latency=$latency ms, CPU=$cpu_util%"
}

# Main execution
echo "Transaction Number,Success (0=success),Latency (ms),CPU Utilization (%),Timestamp" > $OUTPUT_FILE

for i in $(seq 2001 2201); do
    invoke_transaction $i
    # sleep 1 # Add a small delay between transactions
done

echo "Transaction metrics have been written to $OUTPUT_FILE"
