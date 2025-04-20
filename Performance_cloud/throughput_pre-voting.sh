#!/bin/bash

source ./env_variables1.sh

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

# Function to invoke chaincode in the background
VcmsVotingToken() {
    local tx_num=$1
   docker exec -i cli  peer chaincode invoke -o orderer.example.com:7050 \
        -C $CHANNEL_NAME -n ${CC_NAME}  \
        --peerAddresses peer0.org1.example.com:7051 \
        --peerAddresses peer0.org2.example.com:9051 \
        --peerAddresses peer0.org3.example.com:11051 \
        -c '{"function": "VcmsVotingToken","Args":["'$tx_num'","digitalsignature"]}' \
        >/dev/null &
}

OUTPUT_FILE="throughput-prevoting.csv"
start_tx=10070000
Num_of_tx=100

# Capture initial resource usage
start_usage=($(get_cpu_memory_usage))

# Record start time
start_time=$(date +%s%N)

# Start all transactions in the background
for i in $(seq $start_tx $((start_tx+Num_of_tx-1))); 
do
    VcmsVotingToken $i
done

# Wait for all background processes to complete
wait

# Record end time
end_time=$(date +%s%N)

# Calculate duration in seconds
duration_ns=$((end_time - start_time))
duration=$(echo "scale=2; $duration_ns / 1000000000" | bc)

# Calculate throughput
throughput=$(echo "scale=2; $Num_of_tx / $duration" | bc)

# Capture final resource usage
end_usage=($(get_cpu_memory_usage))
cpu_diff=$(echo "${end_usage[0]} - ${start_usage[0]}" | bc)
mem_diff=$(echo "${end_usage[1]} - ${start_usage[1]}" | bc)

# Write results to file
echo "Metric,Value" >> $OUTPUT_FILE
echo "Number of Transactions,$Num_of_tx" >> $OUTPUT_FILE
echo "Total Duration (s),$duration" >> $OUTPUT_FILE
echo "Throughput (TPS),$throughput" >> $OUTPUT_FILE
echo "CPU Usage Increase (%),$cpu_diff" >> $OUTPUT_FILE
echo "Memory Usage Increase (MB),$mem_diff" >> $OUTPUT_FILE

echo "Throughput evaluation complete. Results saved to $OUTPUT_FILE"