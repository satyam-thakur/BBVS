#!/bin/env bash

source ./env_variables1.sh

export CHANNEL_NAME=mychannel

CHANNEL_NAME="mychannel"
CC_RUNTIME_LANGUAGE="golang"
VERSION="1"
CC_NAME="voting8"

PostVoting() {
    local tx_num=$1
   docker exec cli  peer chaincode invoke -o orderer.example.com:7050 \
        -C $CHANNEL_NAME -n ${CC_NAME}  \
        --peerAddresses peer0.org1.example.com:7051 \
        --peerAddresses peer0.org2.example.com:9051 \
        --peerAddresses peer0.org3.example.com:11051 \
        --peerAddresses peer0.org4.example.com:14051 \
        --peerAddresses peer0.org5.example.com:15051 \
        -c '{"function": "PostVoting","Args":["'$tx_num'","voting_token"]}' \
        >/dev/null &
}

OUTPUT_FILE="Post-Voting_batch_throughput-5val.csv"
echo "time,transactions,batch_throughput_TPS,avg_tx_duration_ms" >> $OUTPUT_FILE

start_tx=500000
Num_of_tx=10000 # Total number of transactions
batch_size=100  # Transactions per second

start_time=$(date +%s)
start_usage=$(get_cpu_memory_usage)
start_cpu=$(echo $start_usage | awk '{print $1}')
start_memory=$(echo $start_usage | awk '{print $2}')

echo "start_usage CPU= ${start_cpu}% Memory= ${start_memory}MB"
echo "Running for Total $Num_of_tx transactions of Batch size $batch_size in background"

for ((i=start_tx; i<start_tx+Num_of_tx; i+=batch_size)); do
  batch_start=$(date +%s%N)
  
  for ((j=i; j<i+batch_size && j<start_tx+Num_of_tx; j++)); do
    start_tx_time=$(date +%s%N)
    PostVoting $j
    end_tx_time=$(date +%s%N)
    tx_duration=$((end_tx_time - start_tx_time))
  done

  wait
  
  batch_end=$(date +%s%N)
  batch_duration=$((batch_end - batch_start))
  
  batch_tps=$(bc <<< "scale=2; $batch_size / ($batch_duration / 1000000000)")
  batch_tx_duration_ms=$(bc <<< "scale=2; $batch_duration / $batch_size / 1000000")

  echo "$((($(date +%s) - start_time))), $batch_size, $batch_tps, $batch_tx_duration_ms" >> $OUTPUT_FILE
done

end_time=$(date +%s)
end_usage=$(get_cpu_memory_usage)
end_cpu=$(echo $end_usage | awk '{print $1}')
end_memory=$(echo $end_usage | awk '{print $2}')

total_duration=$((end_time - start_time))
avg_throughput=$(bc <<< "scale=2; $Num_of_tx / $total_duration")
cpu_diff=$(bc <<< "$end_cpu - $start_cpu")
memory_diff=$(bc <<< "$end_memory - $start_memory")

echo "Total transactions: $Num_of_tx" >> $OUTPUT_FILE
echo "Total duration: $total_duration seconds" >> $OUTPUT_FILE
echo "Average throughput: $avg_throughput TPS" >> $OUTPUT_FILE
echo "CPU usage difference: $cpu_diff%" >> $OUTPUT_FILE
echo "Memory usage difference: $memory_diff MB" >> $OUTPUT_FILE

echo "end_usage CPU= ${end_cpu}% Memory= ${end_memory}MB"