#!/bin/bash

source ./env_variables.sh

# Channel name
export CHANNEL_NAME="mychannel"
echo $CHANNEL_NAME

# Create the channel
createChannel(){
    rm -rf ./channel-artifacts/${CHANNEL_NAME}.block
    setGlobalsForPeer0Org1
    peer channel create -o localhost:7050 -c $CHANNEL_NAME \
    -f ./artifacts/channel/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block
}

# Join peers to the channel
joinChannel(){
    setGlobalsForPeer0Org1
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block

    setGlobalsForPeer1Org1
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block

    setGlobalsForPeer0Org2
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block

    setGlobalsForPeer1Org2
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block

    setGlobalsForPeer0Org3
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block

    # setGlobalsForPeer0Org4
    # peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block

    # setGlobalsForPeer0Org5
    # peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block

    # setGlobalsForPeer0Org6
    # peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block

    # setGlobalsForPeer0Org7
    # peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block

    # setGlobalsForPeer0Org8
    # peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block

    # setGlobalsForPeer0Org9
    # peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block

}

# Update anchor peers for each organization
updateAnchorPeers(){
    setGlobalsForPeer0Org1
    peer channel update -o localhost:7050 -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx

    setGlobalsForPeer0Org2
    peer channel update -o localhost:7050 -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx

    setGlobalsForPeer0Org3
    peer channel update -o localhost:7050 -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx

    # setGlobalsForPeer0Org4
    # peer channel update -o localhost:7050 -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx

    # setGlobalsForPeer0Org5
    # peer channel update -o localhost:7050 -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx

    # setGlobalsForPeer0Org6
    # peer channel update -o localhost:7050 -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx

    # setGlobalsForPeer0Org7
    # peer channel update -o localhost:7050 -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx

    # setGlobalsForPeer0Org8
    # peer channel update -o localhost:7050 -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx

    # setGlobalsForPeer0Org9
    # peer channel update -o localhost:7050 -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx
}

# Execute the functions
createChannel
joinChannel
updateAnchorPeers
