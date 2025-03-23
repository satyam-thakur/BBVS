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
    export GOFLAGS="-buildvcs=false"

    setGlobalsForPeer0Org1
    peer lifecycle chaincode package ${CC_NAME}.tar.gz \
        --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} \
        --label ${CC_NAME}_${VERSION} 
    echo "===================== Chaincode is packaged on peer0.org1 ===================== "
}
# packageChaincode

installChaincode() {
    setGlobalsForPeer0Org1
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.org1 ===================== "

}

# installChaincode

queryInstalled() {
    setGlobalsForPeer0Org1
    peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    PACKAGE_ID=$(sed -n "/${CC_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID}
    echo "===================== Query installed successful on peer0.org1 on channel ===================== "
}

# queryInstalled

approveForMyOrg1() {
    setGlobalsForPeer0Org1
    # set -x
    peer lifecycle chaincode approveformyorg -o orderer.example.com:7050 \
        --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --version ${VERSION} --init-required --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}
    # set +x

    echo "===================== chaincode approved from org 1 ===================== "

}

# approveForMyOrg1

getBlock() {
    setGlobalsForPeer0Org1
    peer channel getinfo  -c ${CHANNEL_NAME} -o orderer.example.com:7050 
}

# getBlock

checkCommitReadyness() {
    setGlobalsForPeer0Org1
    peer lifecycle chaincode checkcommitreadiness \
        --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from org 1 ===================== "
}

# checkCommitReadyness
approveForMyOrg2() {
    setGlobalsForPeer0Org2
    peer lifecycle chaincode approveformyorg -o orderer.example.com:7050 \
        --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --init-required --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}

    echo "===================== chaincode approved from org 2 ===================== "
}

# approveForMyOrg2

checkCommitReadyness() {

    setGlobalsForPeer0Org2
    peer lifecycle chaincode checkcommitreadiness \
        --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from org 1 ===================== "
}

# checkCommitReadyness

approveForMyOrg3() {
    setGlobalsForPeer0Org3

    peer lifecycle chaincode approveformyorg -o orderer.example.com:7050 \
        --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --version ${VERSION} --init-required --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}

    echo "===================== chaincode approved from org 3 ===================== "
}

# approveForMyOrg3

# checkCommitReadyness

commitChaincodeDefination() {
    setGlobalsForPeer0Org1
    peer lifecycle chaincode commit -o orderer.example.com:7050  \
        --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --peerAddresses fabric_Org1:7051 \
        --version ${VERSION} --sequence ${VERSION} \
        --init-required 
        # --signature-policy "OutOf(2, 'Org1MSP.peer', 'Org2MSP.peer', 'Org3MSP.peer')"
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
    setGlobalsForPeer0Org1
    peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME}

}

# queryCommitted

chaincodeInvokeInit() {
    setGlobalsForPeer0Org1
    peer chaincode invoke -o orderer.example.com:7050 \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses fabric_Org1:7051 \
        --peerAddresses fabric_Org2:9051 \
        --peerAddresses fabric_Org3:11051 \
        --isInit -c '{"Args":[]}'
}

# chaincodeInvokeInit
#2125b2c332b1113aae9bfc5e9f7e3b4c91d828cb942c2df1eeb02502eccae9e9
VcmsVotingToken() {
    setGlobalsForPeer0Org1
    set -x
    #Input VCMS Data
    peer chaincode invoke -o orderer.example.com:7050 \
        -C $CHANNEL_NAME -n ${CC_NAME}  \
        --peerAddresses fabric_Org1:7051 \
        --peerAddresses fabric_Org2:9051 \
        --peerAddresses fabric_Org3:11051 \
        -c '{"function": "VcmsVotingToken","Args":[ "2125b2c332b1113aae9bfc5e9f7e3b4c91d828cb942c2df1eeb02502eccae9e9","digitalsignature"]}'
    set +x

}

# VcmsVotingToken

VoteCheck(){
    setGlobalsForPeer0Org1
    # set -x
    #Input VCMS Data
    peer chaincode invoke -o orderer.example.com:7050 \
        -C $CHANNEL_NAME -n ${CC_NAME}  \
        --peerAddresses orderer.example.com:7051 \
        -c '{"function": "VoteCheck","Args":["hash002"]}'
    # set +x
}

# VoteCheck

# Ballot_key = 1092c
chaincodeQuery() {
    setGlobalsForPeer0Org2

    # Query voter by Id
    peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"function": "GetBallot","Args":["10cb9"]}'
}

# chaincodeQuery

####=================================================================================####

# Run this function if you add any new dependency in chaincode
# presetup

# packageChaincode
installChaincode
queryInstalled
sleep 3
approveForMyOrg1
checkCommitReadyness
# approveForMyOrg2
# checkCommitReadyness
# approveForMyOrg3
# checkCommitReadyness
# commitChaincodeDefination
queryCommitted
# chaincodeInvokeInit
# sleep 5
# VcmsVotingToken
# sleep 3
# GetVotingTokenRecord
# sleep 3
# # VoteCheck
# # sleep 3
# # chaincodeQuery
