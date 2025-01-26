#!/bin/bash

source ./env_variables.sh

# presetup

CHANNEL_NAME="mychannel"
export CHANNEL_NAME=mychannel
CC_RUNTIME_LANGUAGE="golang"
VERSION="1"
CC_SRC_PATH="./artifacts/src/github.com/Ballot8"
CC_NAME="voting8"

installChaincode() {
    setGlobalsForPeer0Org4
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.org4 ===================== "

    setGlobalsForPeer0Org5
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.org5 ===================== "

}

# installChaincode

queryInstalled() {
    setGlobalsForPeer0Org4
    peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    PACKAGE_ID=$(sed -n "/${CC_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID}
    echo "===================== Query installed successful on peer0.org1 on channel ===================== "
}

# queryInstalled

approveForMyOrg4() {
    setGlobalsForPeer0Org4
    # set -x
    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --version ${VERSION} --init-required --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}
    # set +x

    echo "===================== chaincode approved from org 4 ===================== "

}

# approveForMyOrg4

getBlock() {
    setGlobalsForPeer0Org4
    peer channel getinfo  -c ${CHANNEL_NAME} -o localhost:7050 
}

# getBlock

checkCommitReadyness() {
    setGlobalsForPeer0Org4
    peer lifecycle chaincode checkcommitreadiness \
        --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from org 4 ===================== "
}

# checkCommitReadyness
approveForMyOrg5() {
    setGlobalsForPeer0Org5
    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --init-required --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}

    echo "===================== chaincode approved from org 5 ===================== "
}

# approveForMyOrg5

checkCommitReadyness() {

    setGlobalsForPeer0Org4
    peer lifecycle chaincode checkcommitreadiness \
        --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from org 4 ===================== "
}

# checkCommitReadyness

commitChaincodeDefination() {
    setGlobalsForPeer0Org4
    peer lifecycle chaincode commit -o localhost:7050  \
        --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --peerAddresses localhost:14051 \
        --peerAddresses localhost:15051 \
        --version ${VERSION} --sequence ${VERSION} \
        --init-required
}

# commitChaincodeDefination

# peer lifecycle chaincode commit -o <ORDERER_ADDRESS> \
#     --channelID <CHANNEL_NAME> --name <CHAINCODE_NAME> \
#     --peerAddresses <PEER_ADDRESS_1> [--peerAddresses <PEER_ADDRESS_2> ...] \
#     --version <VERSION> --sequence <SEQUENCE_NUMBER>

#     [--signature-policy <SIGNATURE_POLICY>] \
#     [--ordererTLSHostnameOverride <ORDERER_TLS_HOSTNAME_OVERRIDE>] \
#     [--tls --cafile <ORDERER_CA_FILE>]

queryCommitted() {
    setGlobalsForPeer0Org4
    peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME}

}

# queryCommitted

chaincodeInvokeInit() {
    setGlobalsForPeer0Org4
    peer chaincode invoke -o localhost:7050 \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:14051  \
        --peerAddresses localhost:15051 \
        --isInit -c '{"Args":[]}'
}

# chaincodeInvokeInit

CastVote() {
    setGlobalsForPeer0Org4
    set -x
    #Input VCMS Data
    peer chaincode invoke -o localhost:7050 \
        -C $CHANNEL_NAME -n ${CC_NAME}  \
        --peerAddresses localhost:7051 \
        --peerAddresses localhost:14051 \
        --peerAddresses localhost:15051 \
        -c '{"function": "CastVote","Args":["cCiOJjRLGza2+8s26T7ybA==", "14051"]}'
    set +x

}

# CastVote

getvotingtoken(){
    setGlobalsForPeer0Org4
    set -x
    #Input VCMS Data
    peer chaincode invoke -o localhost:7050 \
        -C $CHANNEL_NAME -n ${CC_NAME}  \
        --peerAddresses localhost:14051 \
        --peerAddresses localhost:15051 \
        -c '{"function": "GetBallot","Args":["01306b"]}'
    set +x
}

Postvotingtoken (){
    setGlobalsForPeer0Org4
    set -x
    peer chaincode invoke -o localhost:7050 \
        -C $CHANNEL_NAME -n ${CC_NAME}  \
        --peerAddresses localhost:7051 \
        --peerAddresses localhost:14051 \
        --peerAddresses localhost:15051 \
        -c '{"function": "PostVoting","Args":["14051", "0123456789ABCDEF"]}'
    set +x
}

# submitvotingtoken

chaincodeQuery() {
    setGlobalsForPeer0Org4

    # Query voter by Id
    peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"function": "GetBallot","Args":["10cb9"]}'
}

# chaincodeQuery


####=================================================================================####

# Run this function if you add any new dependency in chaincode
# presetup


installChaincode
queryInstalled
approveForMyOrg4
checkCommitReadyness
approveForMyOrg5
checkCommitReadyness
commitChaincodeDefination
queryCommitted
chaincodeInvokeInit
sleep 5
CastVote
sleep 3
Postvotingtoken
# sleep 3
# getvotingtoken
# sleep 3
# chaincodeQuery
