#!/bin/bash

# Source environment variables
source ./env_variables1.sh

# Configuration
CHANNEL_NAME="mychannel1"
BLOCK_FILE="blockfile.block"
OUTPUT_FILE="throughput-blocksize-results.csv"

# Initialize variables
PREVIOUS_SIZE=0
PREVIOUS_TIME=$(date +%s%N) # Capture the initial timestamp in nanoseconds

# Initialize output file
echo "Timestamp,Block Size (KB),Throughput (KB/s)" > $OUTPUT_FILE

# Set peer environment for Fabric CLI
setGlobalsForPeer0Org1

# Start monitoring loop
while true; do
    # Fetch the latest block from the channel
    peer channel fetch newest $BLOCK_FILE -c $CHANNEL_NAME 2>/dev/null
    
    # Get the current block size in KB
    CURRENT_SIZE=$(du -k "$BLOCK_FILE" | awk '{print $1}' || echo 0)
    
    # Get the current timestamp in nanoseconds
    CURRENT_TIME=$(date +%s%N)

    # Calculate time difference in seconds
    TIME_DIFF_NS=$((CURRENT_TIME - PREVIOUS_TIME))
    if [ "$TIME_DIFF_NS" -le 0 ]; then
        echo "$(date): Invalid time difference detected. Skipping throughput calculation."
        sleep 5
        continue
    fi
    TIME_DIFF_S=$(echo "scale=2; $TIME_DIFF_NS / 1000000000" | bc)

    # Calculate size difference and throughput only if block size increased
    if [ "$CURRENT_SIZE" -gt "$PREVIOUS_SIZE" ]; then
        SIZE_DIFF=$((CURRENT_SIZE - PREVIOUS_SIZE))
        THROUGHPUT=$(echo "scale=2; $SIZE_DIFF / $TIME_DIFF_S" | bc)

        # Log results to console and output file
        TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
        echo "$TIMESTAMP: New block added, block size: ${CURRENT_SIZE} KB, throughput: ${THROUGHPUT} KB/s"
        echo "$TIMESTAMP,$CURRENT_SIZE,$THROUGHPUT" >> $OUTPUT_FILE

        # Update previous values for next iteration
        PREVIOUS_SIZE=$CURRENT_SIZE
        PREVIOUS_TIME=$CURRENT_TIME
    else
        echo "$(date): Block size decreased or unchanged. Skipping throughput calculation."
    fi

    # Wait before checking again (adjust interval as needed)
    sleep 5
done
