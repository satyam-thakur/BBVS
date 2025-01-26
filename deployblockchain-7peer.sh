#!/bin/bash

set -x

#Run docker-compose up -d
echo "Running ddocker-compose -f "docker-compose_no-tls-7peer.yaml" up -d"
#Change the directory to location of docker-compose
pushd ./artifacts/      
docker-compose -f "docker-compose_no-tls-7peer.yaml" up -d
if [ $? -ne 0 ]; then
    echo "Error running docker-compose up -d"
    exit 1
fi

#Return to original directory
popd

sleep 5

# Run createChannel1.sh
echo "Running createChannel_7peer.sh"
./createChannel_7peer.sh
if [ $? -ne 0 ]; then
    echo "Error running createChannel_7peer.sh"
    exit 1
fi

sleep 5

#Check peer channel list
docker exec peer0.org6.example.com peer channel list
docker exec peer0.org7.example.com peer channel list

sleep 5

# Run deployChaincode1.sh
echo "Running deployChaincode_no-tls1-7peer.sh"
./deployChaincode_no-tls1-7peer.sh
if [ $? -ne 0 ]; then
    echo "Error running deployChaincode_no-tls1-7peer.sh"
    exit 1
fi

sleep 5

# Run deployChaincode.sh
echo "Running deployChaincode_no-tls-7peer.sh"
./deployChaincode_no-tls-7peer.sh
if [ $? -ne 0 ]; then
    echo "Error running deployChaincode_no-tls-7peer.sh"
    exit 1
fi


echo "All scripts executed successfully"

set +x