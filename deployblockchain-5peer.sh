#!/bin/bash

set -x

#Run docker-compose up -d
echo "Running ddocker-compose -f "docker-compose_no-tls-5peer.yaml" up -d"
#Change the directory to location of docker-compose
pushd ./artifacts/      
docker-compose -f "docker-compose_no-tls-5peer.yaml" up -d
if [ $? -ne 0 ]; then
    echo "Error running docker-compose up -d"
    exit 1
fi

#Return to original directory
popd

sleep 5

# Run createChannel1.sh
echo "Running createChannel_5peer.sh"
./createChannel_5peer.sh
if [ $? -ne 0 ]; then
    echo "Error running createChannel_5peer.sh"
    exit 1
fi

sleep 5

#Check peer channel list
docker exec peer0.org4.example.com peer channel list
docker exec peer0.org5.example.com peer channel list

sleep 5

# Run deployChaincode1.sh
echo "Running deployChaincode_no-tls1-5peer.sh"
./deployChaincode_no-tls1-5peer.sh
if [ $? -ne 0 ]; then
    echo "Error running deployChaincode_no-tls1-5peer.sh"
    exit 1
fi

sleep 5

# Run deployChaincode.sh
echo "Running deployChaincode_no-tls-5peer.sh"
./deployChaincode_no-tls-5peer.sh
if [ $? -ne 0 ]; then
    echo "Error running deployChaincode_no-tls-5peer.sh"
    exit 1
fi


echo "All scripts executed successfully"

set +x