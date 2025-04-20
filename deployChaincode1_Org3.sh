#!/bin/bash

source ./env_variables.sh
presetup() {
    echo Vendoring Go dependencies ...
    pushd ./artifacts/src/github.com/fabcar/go
    GO111MODULE=on go mod vendor
    popd
    echo Finished vendoring Go dependencies
}
# presetup

export CHANNEL_NAME="mychannel1"
CHANNEL_NAME="mychannel1"
CC_RUNTIME_LANGUAGE="golang"
VERSION="1"
CC_SRC_PATH="./artifacts/src/github.com/Ballot6"
CC_NAME="voting6"

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
    setGlobalsForPeer0Org1
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
    setGlobalsForPeer0Org1
    docker exec cli peer chaincode invoke -o orderer.example.com:7050 \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses peer0.org1.example.com:7051 \
        --peerAddresses peer0.org2.example.com:9051 \
        --peerAddresses peer0.org3.example.com:11051 \
        --isInit -c '{"Args":[]}'
}
set +x
# chaincodeInvokeInit

VcmsVotingToken() {
    setGlobalsForPeer0Org1
    # set -x
    #Input VCMS Data
    docker exec -it cli peer chaincode invoke -o orderer.example.com:7050 \
        -C $CHANNEL_NAME -n ${CC_NAME}  \
        --peerAddresses peer0.org1.example.com:7051 \
        --peerAddresses peer0.org2.example.com:9051 \
        --peerAddresses peer0.org3.example.com:11051 \
        -c '{"function": "VcmsVotingToken","Args":["3333","digitalsignature"]}' \
        #>/dev/null 
    # set +x

}

# VcmsVotingToken

GetVotingTokenRecord(){
    setGlobalsForPeer0Org1
    # set -x
    #Input VCMS Data
    docker exec cli peer chaincode invoke -o orderer.example.com:7050 \
        -C $CHANNEL_NAME -n ${CC_NAME}  \
        --peerAddresses peer0.org1.example.com:7051 \
        -c '{"function": "GetVotingTokenRecord","Args":["3333"]}'
    # set +x
}

# GetVotingTokenRecord

####=================================================================================####

# Run this function if you add any new dependency in chaincode
# presetup

# set +x
# packageChaincode
installChaincode
queryInstalled
approveForMyOrg3
checkCommitReadiness
# commitChaincodeDefination
# sleep 3
# chaincodeInvokeInit
# sleep 3
# VcmsVotingToken
# sleep 3
# GetVotingTokenRecord
# sleep 3
# set -x