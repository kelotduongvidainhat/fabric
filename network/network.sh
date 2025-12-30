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
    echo "Stopping and cleaning up..."
    docker-compose -f docker/docker-compose-test-net.yaml down --volumes --remove-orphans
    
    # Remove generated artifacts
    rm -rf organizations/ordererOrganizations
    rm -rf organizations/peerOrganizations
    rm -rf channel-artifacts
    
    echo "Network is down and cleaned up."
}

# Main script logic
if [ "$1" == "up" ]; then
    network_up
elif [ "$1" == "down" ]; then
    network_down
else
    echo "Usage: ./network.sh [up|down]"
    exit 1
fi
