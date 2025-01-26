#!/bin/bash

set -x

#Run docker-compose up -d
echo "Running ddocker-compose -f "docker-compose_no-tls-9peer.yaml" up -d"
#Change the directory to location of docker-compose
pushd ./artifacts/      
docker-compose -f "docker-compose_no-tls-9peer.yaml" up -d
if [ $? -ne 0 ]; then
    echo "Error running docker-compose up -d"
    exit 1
fi

#Return to original directory
popd

sleep 5

# Run createChannel1.sh
echo "Running createChannel_9peer.sh"
./createChannel_9peer.sh
if [ $? -ne 0 ]; then
    echo "Error running createChannel_9peer.sh"
    exit 1
fi

sleep 5

#Check peer channel list
docker exec peer0.org8.example.com peer channel list
docker exec peer0.org9.example.com peer channel list

sleep 5

# Run deployChaincode1.sh
echo "Running deployChaincode_no-tls1-9peer.sh"
./deployChaincode_no-tls1-9peer.sh
if [ $? -ne 0 ]; then
    echo "Error running deployChaincode_no-tls1-9peer.sh"
    exit 1
fi

sleep 5

# Run deployChaincode.sh
echo "Running deployChaincode_no-tls-9peer.sh"
./deployChaincode_no-tls-9peer.sh
if [ $? -ne 0 ]; then
    echo "Error running deployChaincode_no-tls-9peer.sh"
    exit 1
fi


echo "All scripts executed successfully"

set +x