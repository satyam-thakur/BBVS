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

export CHANNEL_NAME="mychannel"
CHANNEL_NAME="mychannel"
CC_RUNTIME_LANGUAGE="golang"
VERSION="1"
CC_SRC_PATH="./artifacts/src/github.com/Ballot8"
CC_NAME="voting8"

packageChaincode() {
    rm -rf ${CC_NAME}.tar.gz
    export GOFLAGS="-buildvcs=false"

    setGlobalsForPeer0Org4
    peer lifecycle chaincode package ${CC_NAME}.tar.gz \
        --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} \
        --label ${CC_NAME}_${VERSION} 
    echo "===================== Chaincode is packaged on peer0.org2 ===================== "
}
# packageChaincode

installChaincode() {
    setGlobalsForPeer0Org4
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.org2 ===================== "

}

# installChaincode

queryInstalled() {
    setGlobalsForPeer0Org4
    peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    PACKAGE_ID=$(sed -n "/${CC_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID}
    echo "===================== Query installed successful on peer0.org2 on channel ===================== "
}

# queryInstalled

approveForMyorg2() {
    setGlobalsForPeer0Org4
    # set -x
    peer lifecycle chaincode approveformyorg -o orderer.example.com:7050 \
        --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --version ${VERSION} --init-required --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}
    # set +x

    echo "===================== chaincode approved from org 1 ===================== "

}

# approveForMyorg2

getBlock() {
    setGlobalsForPeer0Org4
    peer channel getinfo  -c ${CHANNEL_NAME} -o orderer.example.com:7050 
}

# getBlock

checkCommitReadyness() {
    setGlobalsForPeer0Org4
    peer lifecycle chaincode checkcommitreadiness \
        --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from org 2 ===================== "
}

# checkCommitReadyness

queryCommitted() {
    setGlobalsForPeer0Org4
    peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME} 

}

# queryCommitted

####=================================================================================####

# Run this function if you add any new dependency in chaincode
# presetup

# packageChaincode
installChaincode
sleep 1
queryInstalled
sleep 3
approveForMyorg2
sleep 1
checkCommitReadyness
# queryCommitted

