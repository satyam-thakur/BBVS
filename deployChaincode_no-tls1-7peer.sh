#!/bin/bash

source ./env_variables.sh

export CHANNEL_NAME="mychannel1"
CHANNEL_NAME="mychannel1"
CC_RUNTIME_LANGUAGE="golang"
VERSION="1"
CC_SRC_PATH="./artifacts/src/github.com/Ballot6"
CC_NAME="voting6"


installChaincode() {
    setGlobalsForPeer0Org6
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.Org6 ===================== "

    setGlobalsForPeer0Org7
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.Org7 ===================== "

}

# installChaincode

queryInstalled() {
    setGlobalsForPeer0Org6
    peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    PACKAGE_ID=$(sed -n "/${CC_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID}
    echo "===================== Query installed successful on peer0.org6 on channel ===================== "
}

# queryInstalled

approveForMyOrg6() {
    setGlobalsForPeer0Org6
    # set -x
    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --version ${VERSION} --init-required --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}
    # set +x

    echo "===================== chaincode approved from org6 ===================== "

}

# approveForMyOrg6

getBlock() {
    setGlobalsForPeer0Org6
    peer channel getinfo  -c ${CHANNEL_NAME} -o localhost:7050 
}

# getBlock

checkCommitReadyness() {
    setGlobalsForPeer0Org6
    peer lifecycle chaincode checkcommitreadiness \
        --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from org6 ===================== "
}

# checkCommitReadyness
approveForMyOrg7() {
    setGlobalsForPeer0Org7
    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --init-required --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}

    echo "===================== chaincode approved from org7 ===================== "
}

# approveForMyOrg7

checkCommitReadyness() {

    setGlobalsForPeer0Org1
    peer lifecycle chaincode checkcommitreadiness \
        --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from org 1 ===================== "
}

# checkCommitReadyness

commitChaincodeDefination() {
    setGlobalsForPeer0Org6
    peer lifecycle chaincode commit -o localhost:7050  \
        --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --peerAddresses localhost:7051 \
        --peerAddresses localhost:16051 \
        --peerAddresses localhost:17051 \
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
    setGlobalsForPeer0Org6
    peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME}

}

# queryCommitted

chaincodeInvokeInit() {
    setGlobalsForPeer0Org6
    peer chaincode invoke -o localhost:7050 \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:7051  \
        --peerAddresses localhost:16051  \
        --peerAddresses localhost:17051 \
        --isInit -c '{"Args":[]}'
}

# chaincodeInvokeInit

#2125b2c332b1113aae9bfc5e9f7e3b4c91d828cb942c2df1eeb02502eccae9e9
VcmsVotingToken() {
    setGlobalsForPeer0Org6
    set -x
    #Input VCMS Data
    peer chaincode invoke -o localhost:7050 \
        -C $CHANNEL_NAME -n ${CC_NAME}  \
        --peerAddresses localhost:7051 \
        --peerAddresses localhost:16051 \
        --peerAddresses localhost:17051 \
        -c '{"function": "VcmsVotingToken","Args":[ "16051","digitalsignature"]}'
    set +x

}

# VcmsVotingToken

GetVotingTokenRecord(){
    setGlobalsForPeer0Org1
    set -x
    #Input VCMS Data
    peer chaincode invoke -o localhost:7050 \
        -C $CHANNEL_NAME -n ${CC_NAME}  \
        --peerAddresses localhost:7051 \
        -c '{"function": "GetVotingTokenRecord","Args":["16051"]}'
    set +x
}

# GetVotingTokenRecord

####=================================================================================####

# Run this function if you add any new dependency in chaincode

installChaincode
queryInstalled
approveForMyOrg6
checkCommitReadyness
approveForMyOrg7
checkCommitReadyness
commitChaincodeDefination
queryCommitted
# chaincodeInvokeInit
sleep 5
VcmsVotingToken
sleep 3
GetVotingTokenRecord
sleep 3