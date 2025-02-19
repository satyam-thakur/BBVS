#!/bin/bash

source ./env_variables1.sh

CHANNEL_NAME="mychannel"
BLOCK_FILE="blockfile-voting.block"
PREVIOUS_SIZE=0

setGlobalsForPeer0Org1
while true; do
    # Fetch the latest block
    peer channel fetch newest $BLOCK_FILE -c $CHANNEL_NAME 2>/dev/null
    
    # # Check if block file exists and get its size
    # if [ ! -f "$BLOCK_FILE" ]; then
    #     echo "Block file not found. Skipping size check."
    #     CURRENT_SIZE=0
    # else
        CURRENT_SIZE=$(du -k "$BLOCK_FILE" | awk '{print $1}' || echo 0)
    # fi

    # Compare sizes and log if a new block is added
    if [ -n "$CURRENT_SIZE" ] && [ -n "$PREVIOUS_SIZE" ] && [ "$CURRENT_SIZE" -ne "$PREVIOUS_SIZE" ]; then
        echo "$(date): New block added, current block size: ${CURRENT_SIZE} KB"
        PREVIOUS_SIZE=$CURRENT_SIZE
    fi
    
    # Wait before checking again
    sleep 5
done
