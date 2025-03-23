#!/bin/bash

source ./env_variables.sh

# set -x

# Channel name
export CHANNEL_NAME="mychannel"
echo $CHANNEL_NAME

# Create the channel
createChannel(){
    rm -rf ./channel-artifacts/${CHANNEL_NAME}.block
    sleep 2
    setGlobalsForPeer0Org1
    peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME \
    -f ./artifacts/channel/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block
}

# Join peers to the channel
joinChannel(){
    setGlobalsForPeer0Org2
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block

}

# Update anchor peers for each organization
updateAnchorPeers(){
    setGlobalsForPeer0Org2
    peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx

}

# Execute the functions
# createChannel
joinChannel
updateAnchorPeers

####################################################################

export CHANNEL_NAME1=mychannel1
echo $CHANNEL_NAME1

# Create the channel
createChannel1(){
    rm -rf ./channel-artifacts/${CHANNEL_NAME1}.block
    sleep 2

    setGlobalsForPeer0Org2

    peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME1 \
    -f ./artifacts/channel/${CHANNEL_NAME1}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME1}.block
}

# Join peers to the channel
joinChannel1(){
    setGlobalsForPeer0Org2
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME1.block


}

# Update anchor peers for each organization
updateAnchorPeers1(){
    setGlobalsForPeer0Org2
    peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME1 -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors1.tx

}

# Execute the functions
# createChannel1
joinChannel1
updateAnchorPeers1



# setGlobalsForPeer0Org2

set +x