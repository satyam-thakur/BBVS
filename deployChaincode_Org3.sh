#!/bin/bash

source ./env_variables.sh

# presetup

CHANNEL_NAME="mychannel"
export CHANNEL_NAME=mychannel
CC_RUNTIME_LANGUAGE="golang"
VERSION="1"
CC_SRC_PATH="./artifacts/src/github.com/Ballot8"
CC_NAME="voting8"

packageChaincode() {
    rm -rf ${CC_NAME}.tar.gz
    setGlobalsForPeer0Org3
    export GOFLAGS="-buildvcs=false"

    peer lifecycle chaincode package ${CC_NAME}.tar.gz \
        --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} \
        --label ${CC_NAME}_${VERSION}
    echo "===================== Chaincode is packaged on peer0.org1 ===================== "
}
# packageChaincode

installChaincode() {
    setGlobalsForPeer0Org3
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.org3 ===================== "
}

# installChaincode

queryInstalled() {
    setGlobalsForPeer0Org3
    peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    PACKAGE_ID=$(sed -n "/${CC_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID}
    echo "===================== Query installed successful on peer0.org1 on channel ===================== "
}

# queryInstalled

approveForMyOrg3() {
    setGlobalsForPeer0Org3

    peer lifecycle chaincode approveformyorg -o orderer.example.com:7050 \
        --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --version ${VERSION} --init-required --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}

    echo "===================== chaincode approved from org 3 ===================== "
}

# approveForMyOrg3


checkCommitReadiness() {
    setGlobalsForPeer0Org3
    peer lifecycle chaincode checkcommitreadiness \
        --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --init-required --sequence ${VERSION} --output json
    echo "===================== checking commit readiness from org 3 ===================== "
}

# checkCommitReadiness

commitChaincodeDefination() {
    setGlobalsForPeer0Org3
    docker exec cli peer lifecycle chaincode commit -o orderer.example.com:7050  \
        --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --peerAddresses peer0.org1.example.com:7051 \
        --peerAddresses peer0.org2.example.com:9051 \
        --peerAddresses peer0.org3.example.com:11051 \
        --version ${VERSION} --sequence ${VERSION} \
        --init-required
}


queryCommitted() {
    setGlobalsForPeer0Org3
    peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME}

}

# queryCommitted
set -x
chaincodeInvokeInit() {
    setGlobalsForPeer0Org3
    docker exec cli peer chaincode invoke -o orderer.example.com:7050 \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses peer0.org1.example.com:7051 \
        --peerAddresses peer0.org2.example.com:9051 \
        --peerAddresses peer0.org3.example.com:11051 \
        --isInit -c '{"Args":[]}'
}
set +x
# chaincodeInvokeInit

CastVote() {
    setGlobalsForPeer0Org1
    set -x
    #Input VCMS Data
    docker exec cli peer chaincode invoke -o orderer.example.com:7050 \
        -C $CHANNEL_NAME -n ${CC_NAME}  \
        --peerAddresses peer0.org1.example.com:7051 \
        --peerAddresses peer0.org2.example.com:9051 \
        --peerAddresses peer0.org3.example.com:11051 \
        -c '{"function": "CastVote","Args":["President_X", "123123"]}'
    set +x

}

# CastVote

QueryCastVote(){
    setGlobalsForPeer0Org3
    set -x
    #Input VCMS Data
    docker exec cli peer chaincode invoke -o orderer.example.com:7050 \
        -C $CHANNEL_NAME -n ${CC_NAME}  \
        --peerAddresses peer0.org1.example.com:7051 \
        --peerAddresses peer0.org2.example.com:9051 \
        --peerAddresses peer0.org3.example.com:11051 \
        -c '{"function": "QueryCastVote","Args":["123123"]}'
    set +x
}

Postvotingtoken (){
    setGlobalsForPeer0Org1
    set -x
    docker exec cli peer chaincode invoke -o orderer.example.com:7050 \
        -C $CHANNEL_NAME -n ${CC_NAME}  \
        --peerAddresses peer0.org1.example.com:7051 \
        --peerAddresses peer0.org2.example.com:9051 \
        --peerAddresses peer0.org3.example.com:11051 \
        -c '{"function": "PostVoting","Args":["123123", "digitalsignature"]}'
    set +x
}

# Postvotingtoken

QueryPostVoting (){
    setGlobalsForPeer0Org3
    docker exec cli peer chaincode invoke -o orderer.example.com:7050 \
        -C $CHANNEL_NAME -n ${CC_NAME}  \
        --peerAddresses peer0.org1.example.com:7051 \
        --peerAddresses peer0.org2.example.com:9051 \
        --peerAddresses peer0.org3.example.com:11051 \
        -c '{"function": "QueryPostVoting","Args":["123123"]}'
}

# QueryPostVoting

####=================================================================================####

# Run this function if you add any new dependency in chaincode
# presetup

# packageChaincode
installChaincode
queryInstalled
approveForMyOrg3
checkCommitReadiness
#######################################################################################
# commitChaincodeDefination
# sleep 3
# chaincodeInvokeInit
# sleep 3
# CastVote
# sleep 5
# QueryCastVote
# sleep 3
# Postvotingtoken
# sleep 4
# QueryPostVoting
