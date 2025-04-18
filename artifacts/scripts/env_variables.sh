#!/bin/bash

# set -x

# Disable TLS
export CORE_PEER_TLS_ENABLED=false

# Set configuration paths
export FABRIC_CFG_PATH=${PWD}/artifacts/channel/config/

# Set global environment variables for the orderer
setGlobalsForOrderer(){
    export CORE_PEER_LOCALMSPID="OrdererMSP"
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp
}

# Set global environment variables for Peer0 in Org1
setGlobalsForPeer0Org1(){
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

# Set global environment variables for Peer1 in Org1
setGlobalsForPeer1Org1(){
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:8051
}

# Set global environment variables for Peer0 in Org2
setGlobalsForPeer0Org2(){
    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051
}

# Set global environment variables for Peer1 in Org2
setGlobalsForPeer1Org2(){
    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:10051
}

# Set global environment variables for Peer0 in Org3
setGlobalsForPeer0Org3(){
    export CORE_PEER_LOCALMSPID="Org3MSP"
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp
    export CORE_PEER_ADDRESS=localhost:11051
}

# Set global environment variables for peer0 in org4
setGlobalsForPeer0Org4(){
    export CORE_PEER_LOCALMSPID="Org4MSP"
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org4.example.com/users/Admin@org4.example.com/msp
    export CORE_PEER_ADDRESS=localhost:14051
}

# Set global environment variables for peer0 in org5
setGlobalsForPeer0Org5(){
    export CORE_PEER_LOCALMSPID="Org5MSP"
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org5.example.com/users/Admin@org5.example.com/msp
    export CORE_PEER_ADDRESS=localhost:15051
}

# Set global environment variables for peer0 in org6
setGlobalsForPeer0Org6(){
    export CORE_PEER_LOCALMSPID="Org6MSP"
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org6.example.com/users/Admin@org6.example.com/msp
    export CORE_PEER_ADDRESS=localhost:16051
}

# Set global environment variables for peer0 in org7
setGlobalsForPeer0Org7(){
    export CORE_PEER_LOCALMSPID="Org7MSP"
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org7.example.com/users/Admin@org7.example.com/msp
    export CORE_PEER_ADDRESS=localhost:17051
}

# Set global environment variables for peer0 in org8
setGlobalsForPeer0Org8(){
    export CORE_PEER_LOCALMSPID="Org8MSP"
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org8.example.com/users/Admin@org8.example.com/msp
    export CORE_PEER_ADDRESS=localhost:18051
}

# Set global environment variables for peer0 in org9
setGlobalsForPeer0Org9(){
    export CORE_PEER_LOCALMSPID="Org9MSP"
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org9.example.com/users/Admin@org9.example.com/msp
    export CORE_PEER_ADDRESS=localhost:19051
}

# Set global environment variables for peer0 in org10
setGlobalsForPeer0Org10(){
    export CORE_PEER_LOCALMSPID="Org10MSP"
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org10.example.com/users/Admin@org10.example.com/msp
    export CORE_PEER_ADDRESS=localhost:20051
}

set +x
