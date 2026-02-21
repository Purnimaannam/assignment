#!/bin/bash

# Wallet API Setup Script for Linux/Mac

echo ""
echo "==============================================="
echo "Wallet API - Setup Environment"
echo "==============================================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Check prerequisites
echo "Checking prerequisites..."

if ! command -v docker &> /dev/null; then
    echo -e "${RED}[ERROR] Docker is not installed${NC}"
    exit 1
fi
echo -e "${GREEN}[OK] Docker found${NC}"

if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}[ERROR] Docker Compose is not installed${NC}"
    exit 1
fi
echo -e "${GREEN}[OK] Docker Compose found${NC}"

if ! command -v mvn &> /dev/null; then
    echo -e "${RED}[ERROR] Maven is not installed${NC}"
    exit 1
fi
echo -e "${GREEN}[OK] Maven found${NC}"

# Build
echo ""
echo "Building the application..."
mvn clean package

if [ $? -ne 0 ]; then
    echo -e "${RED}[ERROR] Build failed${NC}"
    exit 1
fi
echo -e "${GREEN}[OK] Build successful${NC}"

# Start services
echo ""
echo "Starting Docker containers..."
docker-compose up -d

if [ $? -ne 0 ]; then
    echo -e "${RED}[ERROR] Failed to start containers${NC}"
    exit 1
fi
echo -e "${GREEN}[OK] Containers started${NC}"

# Wait for services
echo ""
echo "Waiting for services to be ready (30 seconds)..."
sleep 30

# Health check
echo ""
echo "Testing API health..."
curl -s http://localhost:8080/actuator/health | jq .

echo ""
echo "==============================================="
echo -e "${GREEN}Setup complete!${NC}"
echo "API is ready at http://localhost:8080"
echo "==============================================="
