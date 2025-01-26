#!/bin/bash

set -x

#Run docker-compose up -d
echo "Running docker-compose up -d"
#Change the directory to location of docker-compose
pushd ./artifacts/      
docker-compose -f "docker-compose_no-tls.yaml" up -d
if [ $? -ne 0 ]; then
    echo "Error running docker-compose up -d"
    exit 1
fi

#Return to original directory
popd

sleep 5

# Run createChannel1.sh
echo "Running createChannel_no-tls.sh"
./createChannel_no-tls.sh
if [ $? -ne 0 ]; then
    echo "Error running createChannel_no-tls.sh"
    exit 1
fi

sleep 5

#Check peer channel list
docker exec peer0.org1.example.com peer channel list
docker exec peer1.org1.example.com peer channel list
docker exec peer0.org2.example.com peer channel list
docker exec peer1.org2.example.com peer channel list
docker exec peer0.org3.example.com peer channel list

sleep 5

# Run deployChaincode1.sh
echo "Running deployChaincode_no-tls1.sh"
./deployChaincode_no-tls1.sh
if [ $? -ne 0 ]; then
    echo "Error running deployChaincode_no-tls1.sh"
    exit 1
fi

sleep 5

# Run deployChaincode.sh
echo "Running deployChaincode_no-tls.sh"
./deployChaincode_no-tls.sh
if [ $? -ne 0 ]; then
    echo "Error running deployChaincode_no-tls.sh"
    exit 1
fi


echo "All scripts executed successfully"

set +x