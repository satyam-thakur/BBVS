#!/bin/bash

source ./env_variables.sh

export CHANNEL_NAME="mychannel1"
CHANNEL_NAME="mychannel1"
CC_RUNTIME_LANGUAGE="golang"
VERSION="1"
SEQ_VERSION="2"
CC_SRC_PATH="./artifacts/src/github.com/Ballot6"
CC_NAME="voting6"


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

    setGlobalsForPeer0Org5
    peer lifecycle chaincode checkcommitreadiness \
        --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --sequence ${SEQ_VERSION} --output json --init-required
    echo "===================== checking commit readyness from org 5 ===================== "
}

# checkCommitReadyness

commitChaincodeDefination() {
    setGlobalsForPeer0Org4
    peer lifecycle chaincode commit -o localhost:7050  \
        --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --peerAddresses localhost:14051 \
        --peerAddresses localhost:15051 \
        --version ${VERSION} --sequence ${SEQ_VERSION} \
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
        --peerAddresses localhost:7051  \
        --peerAddresses localhost:14051  \
        --peerAddresses localhost:15051 \
        --isInit -c '{"Args":[]}'
}

# chaincodeInvokeInit

#2125b2c332b1113aae9bfc5e9f7e3b4c91d828cb942c2df1eeb02502eccae9e9
VcmsVotingToken() {
    setGlobalsForPeer0Org4
    set -x
    #Input VCMS Data
    peer chaincode invoke -o localhost:7050 \
        -C $CHANNEL_NAME -n ${CC_NAME}  \
        --peerAddresses localhost:7051 \
        --peerAddresses localhost:14051 \
        --peerAddresses localhost:15051 \
        -c '{"function": "VcmsVotingToken","Args":[ "14051","digitalsignature"]}'
    set +x

}

# VcmsVotingToken

GetVotingTokenRecord(){
    setGlobalsForPeer0Org1
    set -x
    #Input VCMS Data
    peer chaincode invoke -o localhost:7050 \
        -C $CHANNEL_NAME -n ${CC_NAME}  \
        -c '{"function": "GetVotingTokenRecord","Args":["14051"]}'
    set +x
}

# GetVotingTokenRecord

####=================================================================================####

# Run this function if you add any new dependency in chaincode

installChaincode
queryInstalled
approveForMyOrg4
# checkCommitReadyness
approveForMyOrg5
# checkCommitReadyness
# commitChaincodeDefination
queryCommitted
# chaincodeInvokeInit
# sleep 5
VcmsVotingToken
sleep 3
GetVotingTokenRecord
sleep 3