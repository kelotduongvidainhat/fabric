# Asset Management Application with Hyperledger Fabric

A robust , enterprise-grade asset management system built on **Hyperledger Fabric**, featuring **Chaincode-as-a-Service (CaaS)**, off-chain data synchronization with **PostgreSQL**, and a modern **React** frontend. This application provides a complete lifecycle for asset creation, transfer, history tracking, and provenance.

## 🛠️ Technology Stack & Versions

This project is built using the latest stable technologies:

- **Blockchain Core**: Hyperledger Fabric **v2.5+**
- **Smart Contract (Chaincode)**: Go **v1.22+**
- **Containerization**: Docker & Docker Compose
- **Database**: PostgreSQL **v16** (Off-chain data sync)
- **Backend API**: Go (Gin framework recommended)
- **Frontend**: Node.js **v20+** / React

## ✨ Key Features

- **Asset Lifecycle Management**: Create, Read, Update, and Delete (CRUD) assets on the blockchain.
- **Chaincode-as-a-Service (CaaS)**: Optimized chaincode deployment using external builders and launchers.
- **Asset History & Provenance**: View the complete immutable history of an asset, including modification tracking (e.g., `LastModifiedBy`).
- **Off-Chain Synchronization**: Real-time sync of blockchain data to a PostgreSQL database for complex querying and analytics.
- **Multi-Source Dashboard**: Frontend capability to switch between viewing live blockchain data and indexed database records.
- **Secure Transfers**: Implementation of secure asset transfer logic.

## 📋 Prerequisites

Ensure you have the following installed on your system:

- **Linux** (Ubuntu/Debian recommended) or WSL2 on Windows.
- **Docker** and **Docker Compose** plugin.
- **Go** (v1.22 or higher).
- **Node.js** (v20 or higher) and **npm/yarn**.
- **PostgreSQLClient** (psql) (optional, for manual DB verification).

## 🚀 Installation & Setup (Manual Guide)

Follow these steps to manually set up the environment. This provides a deeper understanding of the components.

### 1. Network Initialization
Start the Hyperledger Fabric test network foundation.
```bash
# Create the docker network if it doesn't exist
docker network creating fabric_test

# Start the Orderer and Peers
# (Assumes you are in the relevant network directory, e.g., test-network)
./network.sh up createChannel -c mychannel -ca
```

### 2. Database Setup (PostgreSQL)
Start the off-chain database.
```bash
# Pull and start PostgreSQL container
docker run -d --name asset-db \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=fabric_assets \
  -p 5432:5432 \
  postgres:16
```

### 3. Chaincode Build & Deployment (CaaS)
This project uses CaaS. You must build the chaincode binary and package it as a Docker image.

**Step A: Build the Go Binary**
```bash
cd chaincode
go build -o chaincode
```

**Step B: Build Docker Image**
```bash
docker build -t my-org/asset-transfer-chaincode:1.0 .
```

**Step C: Deploy via Lifecycle Commands**
Use the standard Fabric lifecycle commands (`peer lifecycle chaincode install/approve/commit`) to deploy the definition pointing to your running CaaS container.

### 4. Backend Service (Listener & API)
The backend listens for block events and syncs them to PostgreSQL.
```bash
cd backend
# Install dependencies
go mod download
# Start the server
go run main.go
```

### 5. Frontend Dashboard
Launch the user interface.
```bash
cd frontend
# Install dependencies
npm install
# Start the development server
npm run dev
```

## ⚡ Automated Setup
For a quick start, you can use the provided helper script which automates the Docker composition and network startup.

```bash
./fresh_start.sh
```
*Note: This script cleans up existing containers and volumes before starting.*

## 📖 Usage Guide

1. **Dashboard**: Navigate to `http://localhost:3000` (default React port).
2. **Create Asset**: Use the "New Asset" form to mint a new token/asset on the ledger.
3. **View History**: Click on an asset to view its timeline and provenance.
4. **Switch Data Source**: Toggle between "Blockchain (Live)" and "Database (Indexed)" to see the sync in action.

## 🔧 Troubleshooting

- **Chaincode Container Unreachable**: Ensure the CaaS container is running on the same Docker network as the peer (`fabric_test`). Check `CHAINCODE_ID` environment variable.
- **Database Connection Refused**: Verify PostgreSQL is running and port 5432 is exposed. Check the connection string in the backend configuration.
- **Peer Connection Failed**: Ensure valid crypto material (MSPs, TLS certificates) are correctly referenced by the application.

---
*Built with ❤️ by the AntiGravity Team*
