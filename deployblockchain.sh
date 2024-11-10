#!/bin/bash

set -x

#Run docker-compose up -d
echo "Running docker-compose up -d"
#Change the directory to location of docker-compose
pushd ./artifacts/      
docker-compose -f docker-compose-persistance.yaml up -d
if [ $? -ne 0]; then
    echo "Error running docker-compose up -d"
    exit 1
fi

#Return to original directory
popd

sleep 5

# Run createChannel1.sh
echo "Running createChannel1.sh"
./createChannel1.sh
if [ $? -ne 0 ]; then
    echo "Error running createChannel1.sh"
    exit 1
fi

sleep 5

# Run createChannel.sh
echo "Running createChannel.sh"
./createChannel.sh
if [ $? -ne 0 ]; then
    echo "Error running createChannel.sh"
    exit 1
fi

#Check peer channel list
docker exec peer0.org1.example.com peer channel list
docker exec peer1.org1.example.com peer channel list
docker exec peer0.org2.example.com peer channel list
docker exec peer1.org2.example.com peer channel list

sleep 5

# Run deployChaincode1.sh
echo "Running deployChaincode1.sh"
./deployChaincode1.sh
if [ $? -ne 0 ]; then
    echo "Error running deployChaincode1.sh"
    exit 1
fi

sleep 5

# Run deployChaincode.sh
echo "Running deployChaincode.sh"
./deployChaincode.sh
if [ $? -ne 0 ]; then
    echo "Error running deployChaincode.sh"
    exit 1
fi


echo "All scripts executed successfully"

set +x