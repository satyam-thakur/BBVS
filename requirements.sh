#!/bin/bash

# Update package lists
sudo apt-get update

# Install required dependencies
sudo apt-get install -y curl wget git software-properties-common apt-transport-https ca-certificates gnupg lsb-release

# Install Go (v1.23.1)
wget https://go.dev/dl/go1.23.1.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.23.1.linux-amd64.tar.gz
rm go1.23.1.linux-amd64.tar.gz

# Set Go environment variables
echo '# Go environment variables' >> ~/.bashrc
echo 'export GOROOT=/usr/local/go' >> ~/.bashrc
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export PATH=$PATH:$GOROOT/bin:$GOPATH/bin' >> ~/.bashrc

# Install Docker
# Remove any existing Docker installations
sudo apt-get remove docker docker-engine docker.io containerd runc

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the stable repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine (version 18.06.3-ce)
sudo apt-get update
sudo apt-get install -y docker-ce=18.06.3~ce~3-0~ubuntu docker-ce-cli=18.06.3~ce~3-0~ubuntu containerd.io
sudo apt-get install docker.io

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
sudo systemctl restart docker.services

# Install Hyperledger Fabric binaries (v2.5.9)
mkdir -p ~/fabric
cd ~/fabric
wget https://github.com/hyperledger/fabric/releases/download/v2.5.9/hyperledger-fabric-linux-amd64-2.5.9.tar.gz
tar -xzf hyperledger-fabric-linux-amd64-2.5.9.tar.gz
rm hyperledger-fabric-linux-amd64-2.5.9.tar.gz

# Set Fabric binaries path
echo '# Hyperledger Fabric binaries' >> ~/.bashrc
echo 'export PATH=$PATH:~/fabric/bin' >> ~/.bashrc

# Reload bashrc
source ~/.bashrc

wait 1

source ~/.bashrc

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

