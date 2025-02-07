#!/bin/bash

set -x

#Run docker-compose up -d
echo "Running docker-compose stop"
#Change the directory to location of docker-compose
pushd ./artifacts/      
docker-compose -f "docker-compose_no-tls.yaml" stop
if [ $? -ne 0 ]; then
    echo "Error running docker-compose stop"
    exit 1
fi

docker-compose -f "docker-compose_no-tls-5peer.yaml" stop
if [ $? -ne 0 ]; then
    echo "Error running docker-compose stop"
    exit 1
fi

docker-compose -f "docker-compose_no-tls-5peer.yaml" stop
if [ $? -ne 0 ]; then
    echo "Error running docker-compose stop"
    exit 1
fi

docker-compose -f "docker-compose_no-tls-7peer.yaml" stop
if [ $? -ne 0 ]; then
    echo "Error running docker-compose stop"
    exit 1
fi

docker-compose -f "docker-compose_no-tls-9peer.yaml" stop  
if [ $? -ne 0 ]; then
    echo "Error running docker-compose stop"
    exit 1
fi


#Return to original directory
popd

echo "All scripts executed successfully"

set +x