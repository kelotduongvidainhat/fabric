#!/bin/bash

# Exit on error
set -e

# Import environment variables
export PATH=${PWD}/bin:$PATH
export FABRIC_CFG_PATH=${PWD}/config

# Function to generate crypto material
generate_crypto() {
    echo "Creating crypto material..."
    mkdir -p organizations
    bin/cryptogen generate --config=./organizations/cryptogen/crypto-config.yaml --output="organizations"
}

# Function to generate genesis block
generate_genesis() {
    echo "Generating Orderer Genesis block..."
    mkdir -p channel-artifacts
    bin/configtxgen -profile CustomOrgsOrdererGenesis -channelID system-channel -outputBlock ./channel-artifacts/genesis.block
}

# Function to start the network
network_up() {
    # 1. Generate crypto
    if [ ! -d "organizations/peerOrganizations" ]; then
        generate_crypto
    fi

    # 2. Generate genesis block
    if [ ! -f "channel-artifacts/genesis.block" ]; then
        generate_genesis
    fi

    # 3. Start docker containers
    echo "Starting containers..."
    docker-compose -f docker/docker-compose-test-net.yaml up -d
    
    echo "Network is up!"
}

# Function to stop the network
network_down() {
    echo "Stopping containers..."
    docker-compose -f docker/docker-compose-test-net.yaml stop
}

# Function to clean all network artifacts and volumes
network_clean() {
    echo "Stopping and cleaning up all network resources..."
    docker-compose -f docker/docker-compose-test-net.yaml down --volumes --remove-orphans
    
    # Remove generated artifacts
    echo "Removing generated crypto and artifacts..."
    rm -rf organizations/ordererOrganizations
    rm -rf organizations/peerOrganizations
    rm -rf channel-artifacts
    
    # Clean up any leftover chaincode images
    if [ -n "$(docker images -q dev-peer*)" ]; then
        echo "Removing chaincode images..."
        docker rmi $(docker images -q dev-peer*)
    fi

    echo "Network is down and all artifacts are cleaned up."
}

# Main script logic
if [ "$1" == "up" ]; then
    network_up
elif [ "$1" == "down" ]; then
    network_down
elif [ "$1" == "clean" ]; then
    network_clean
else
    echo "Usage: ./network.sh [up|down|clean]"
    exit 1
fi
