#!/bin/bash

source ./env_variables.sh

set -x

export CHANNEL_NAME=mychannel
echo $CHANNEL_NAME

# Join peers to the channel
joinChannel(){
    setGlobalsForPeer0Org6
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block

    setGlobalsForPeer0Org7
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
}

# Update anchor peers for each organization
updateAnchorPeers(){
    setGlobalsForPeer0Org6
    peer channel update -o localhost:7050 -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx

    setGlobalsForPeer0Org7
    peer channel update -o localhost:7050 -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx
}

# Execute the functions
joinChannel
# updateAnchorPeers

#######################################################################

export CHANNEL_NAME1=mychannel1
echo $CHANNEL_NAME1

# Join peers to the channel
joinChannel1(){
    setGlobalsForPeer0Org6
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME1.block

    setGlobalsForPeer0Org7
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME1.block
}

# Update anchor peers for each organization
updateAnchorPeers1(){
    setGlobalsForPeer0Org6
    peer channel update -o localhost:7050 -c $CHANNEL_NAME1 -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors1.tx

    setGlobalsForPeer0Org7
    peer channel update -o localhost:7050 -c $CHANNEL_NAME1 -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors1.tx
}

# Execute the functions
# joinChannel1
# updateAnchorPeers1