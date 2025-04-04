#!/bin/bash

# Update package lists
sudo apt-get update

# Install required dependencies
sudo apt-get install -y curl wget git software-properties-common apt-transport-https ca-certificates gnupg lsb-release

# Install Go (v1.23.1)
wget https://go.dev/dl/go1.23.1.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.23.1.linux-amd64.tar.gz
# rm go1.23.1.linux-amd64.tar.gz
wait
# sleep 0.5

if [ $? -ne 0 ]; then
    echo "Error Go installing"
    exit 1
fi

# Set Go environment variables
echo '# Go environment variables' >> ~/.bashrc
echo 'export GOROOT=/usr/local/go' >> ~/.bashrc
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export PATH=$PATH:$GOROOT/bin:$GOPATH/bin' >> ~/.bashrc

# Install Docker
# Remove any existing Docker installations
sudo apt-get remove docker docker-engine docker.io containerd runc

# Add Docker's official script
curl -fsSL https://get.docker.com -o get-docker.sh

sudo sh get-docker.sh




wait

if [ $? -ne 0 ]; then
    echo "Error Docker installing"
    exit 1
fi

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
wait

if [ $? -ne 0 ]; then
    echo "Error docker-compose installing"
    exit 1
fi

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
sudo systemctl restart docker.services
wait

# Install Hyperledger Fabric binaries (v2.5.9)
mkdir -p ~/fabric
cd ~/fabric
wget https://github.com/hyperledger/fabric/releases/download/v2.5.9/hyperledger-fabric-linux-amd64-2.5.9.tar.gz
tar -xzf hyperledger-fabric-linux-amd64-2.5.9.tar.gz
# rm hyperledger-fabric-linux-amd64-2.5.9.tar.gz
wait

if [ $? -ne 0 ]; then
    echo "Error Installing fabric binaries"
    exit 1
fi

# Set Fabric binaries path
echo '# Hyperledger Fabric binaries' >> ~/.bashrc
echo 'export PATH=$PATH:~/fabric/bin' >> ~/.bashrc

# Reload bashrc
source ~/.bashrc
wait




# Verify installations
echo "Go version:"
go version

echo "Docker version:"
docker version

echo "Docker Compose version:"
docker-compose version

echo "Peer version:"
peer version

echo "Installation complete! Please log out and log back in or run 'source ~/.bashrc' to apply path changes."