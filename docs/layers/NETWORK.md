# Network Layer Documentation

## Overview

The Network Layer is the foundation of the Asset Management System, built on **Hyperledger Fabric v2.5+**. It provides the distributed ledger infrastructure, identity management, and consensus mechanisms required for secure and immutable asset tracking.

## Architecture

The network is designed with a high-availability modular architecture comprising:

- **Peers**: Nodes that maintain the ledger and run chaincode containers.
- **Orderers**: A 3-node cluster providing consensus using the Raft protocol.
- **CouchDB**: State database for each peer, enabling rich queries.
- **MSP**: Managed Service Provider identities generated via `cryptogen`.
- **Channel**: A private subnet for communication between specific network members.

## Components & Configuration

| Component | Description |
|-----------|-------------|
| **Fabric Version** | v2.5+ |
| **Channel Name** | `mychannel` (default) |
| **Docker Network** | `fabric_test` |
| **Consensus** | Raft (3 Nodes) |
| **State Database** | CouchDB |
| **Security** | Mutual TLS Enabled |

## Initialization Workflow

The network setup is managed via the `network.sh` script located in the `network/` directory.

### 1. Start Network
This step generates crypto material, creates the genesis block, and spins up 8 docker containers.

```bash
cd network
./network.sh up
```

### 2. Network Components
- **Orderer Org**: `orderer1`, `orderer2`, `orderer3`
- **Org1**: `peer0`, `peer1`
- **Databases**: `couchdb0`, `couchdb1`
- **Tools**: `cli`

### 3. Management
```bash
# Stop and clean up the network
./network.sh down

# View logs
docker-compose -f docker/docker-compose-test-net.yaml logs -f
```

## Network Topology

- **Orderer Organization**:
  - **Ordering Service** (Raft Consensus):
    - `orderer1.example.com` (Port 7050)
    - `orderer2.example.com` (Port 8050)
    - `orderer3.example.com` (Port 9050)

- **Org1**:
  - **Peer0** (`peer0.org1.example.com`):
    - Port: 7051
    - State DB: `couchdb0` (Port 5984)
  - **Peer1** (`peer1.org1.example.com`):
    - Port: 8051
    - State DB: `couchdb1` (Port 6984)

## Troubleshooting / Common Issues

- **TLS Handshake Failures**: Ensure crypto material is freshly generated. Run `./network.sh down` then `./network.sh up`.
- **Database Connection**: Ensure `couchdb0` and `couchdb1` are running. Default credentials are `admin/adminpw`.
- **Docker Network Conflicts**: Ensure the `fabric_test` network is not conflicting.
