# Quick Start Guide

Get the Wallet API up and running in 5 minutes!

## Prerequisites

- Java 17 or higher
- Docker and Docker Compose
- Maven 3.6.0 or higher

[See detailed setup instructions in SETUP.md](SETUP.md)

## Quick Start (5 minutes)

### 1. Clone Repository

```bash
git clone <repository-url>
cd wallet-api
```

### 2. Build Application

```bash
mvn clean package -DskipTests
```

### 3. Start Services

```bash
docker-compose up -d
```

### 4. Verify Setup

```bash
# Check services are running
docker-compose ps

# Check health
curl http://localhost:8080/actuator/health
```

**You're ready to go!** The API is running at `http://localhost:8080`

## Basic API Usage

### Create a Wallet

```bash
curl -X POST http://localhost:8080/api/v1/wallet \
  -H "Content-Type: application/json" \
  -d '{
    "walletId": "550e8400-e29b-41d4-a716-446655440000",
    "operationType": "DEPOSIT",
    "amount": 1000.00
  }'
```

**Response:**
```json
{
  "walletId": "550e8400-e29b-41d4-a716-446655440000",
  "balance": 1000.00,
  "updatedAt": "2024-02-21T10:30:45.123456"
}
```

### Get Balance

```bash
curl http://localhost:8080/api/v1/wallets/550e8400-e29b-41d4-a716-446655440000
```

### Deposit Money

```bash
curl -X POST http://localhost:8080/api/v1/wallet \
  -H "Content-Type: application/json" \
  -d '{
    "walletId": "550e8400-e29b-41d4-a716-446655440000",
    "operationType": "DEPOSIT",
    "amount": 500.00
  }'
```

### Withdraw Money

```bash
curl -X POST http://localhost:8080/api/v1/wallet \
  -H "Content-Type: application/json" \
  -d '{
    "walletId": "550e8400-e29b-41d4-a716-446655440000",
    "operationType": "WITHDRAW",
    "amount": 250.00
  }'
```

## Stop Services

```bash
docker-compose down
```

## Common Commands

| Command | Purpose |
|---------|---------|
| `mvn test` | Run all tests |
| `mvn clean package` | Build application |
| `docker-compose ps` | View running containers |
| `docker-compose logs -f` | View logs |
| `docker-compose down` | Stop services |
| `docker-compose down -v` | Stop and remove volumes (database) |

## Using Different Wallets (UUIDs)

Each curl command above shows a specific wallet ID. You can use any UUID:

```bash
# Generate a new UUID and create wallet
WALLET_ID=$(uuidgen)  # On macOS/Linux
# Or on Windows: $WALLET_ID = [guid]::NewGuid().ToString()

curl -X POST http://localhost:8080/api/v1/wallet \
  -H "Content-Type: application/json" \
  -d "{
    \"walletId\": \"$WALLET_ID\",
    \"operationType\": \"DEPOSIT\",
    \"amount\": 1000.00
  }"
```

## Testing

Run the test suite:

```bash
mvn test
```

Run specific test:

```bash
mvn test -Dtest=WalletControllerTest
```

## Configuration

To customize settings, edit the `.env` file:

```env
# Database settings
DB_HOST=postgres
DB_PORT=5432
DB_NAME=walletdb
DB_USER=postgres
DB_PASSWORD=postgres

# Application settings
SERVER_PORT=8080
LOG_LEVEL=INFO
```

Then restart the application:

```bash
docker-compose down
docker-compose up -d
```

## Troubleshooting

### Error: "Connection refused"
- Ensure Docker is running
- Wait for containers to start: `docker-compose ps` should show "up"
- Check logs: `docker-compose logs postgres`

### Error: "Port 8080 already in use"
- Change port in `.env`: `SERVER_PORT=8081`
- Restart: `docker-compose restart`

### Error: "Cannot connect to Docker daemon"
- Start Docker Desktop (on Mac/Windows)
- Or start Docker daemon: `sudo systemctl start docker` (Linux)

## Next Steps

1. **Read full API docs** → [README.md](README.md)
2. **Understand architecture** → [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)
3. **Run load tests** → See [Load Testing](#load-testing) below
4. **Contribute** → [CONTRIBUTING.md](CONTRIBUTING.md)

## Load Testing

### Quick Load Test (10 requests)

```bash
# Linux/macOS
./load-test.sh 10 2

# Windows PowerShell
.\load-test.ps1 -NumRequests 10 -NumConcurrent 2
```

### Heavy Load Test (1000 requests)

```bash
# Linux/macOS
./load-test.sh 1000 50

# Windows PowerShell
.\load-test.ps1 -NumRequests 1000 -NumConcurrent 50
```

## Example: Complete Workflow

```bash
# 1. Create wallet with $1000
WALLET_ID="550e8400-e29b-41d4-a716-446655440000"

curl -X POST http://localhost:8080/api/v1/wallet \
  -H "Content-Type: application/json" \
  -d "{
    \"walletId\": \"$WALLET_ID\",
    \"operationType\": \"DEPOSIT\",
    \"amount\": 1000.00
  }"

# 2. Check balance
curl http://localhost:8080/api/v1/wallets/$WALLET_ID | jq .

# 3. Deposit $500
curl -X POST http://localhost:8080/api/v1/wallet \
  -H "Content-Type: application/json" \
  -d "{
    \"walletId\": \"$WALLET_ID\",
    \"operationType\": \"DEPOSIT\",
    \"amount\": 500.00
  }"

# 4. Withdraw $300
curl -X POST http://localhost:8080/api/v1/wallet \
  -H "Content-Type: application/json" \
  -d "{
    \"walletId\": \"$WALLET_ID\",
    \"operationType\": \"WITHDRAW\",
    \"amount\": 300.00
  }"

# 5. Final balance (should be $1200)
curl http://localhost:8080/api/v1/wallets/$WALLET_ID | jq .balance
```

## Performance Highlights

- ✅ Handles **1000+ concurrent requests per wallet**
- ✅ **Optimistic locking** ensures data consistency
- ✅ **Automatic retry** on transient failures
- ✅ Connection pooling for efficient database access
- ✅ Comprehensive error handling (no 5XX for client errors)

## Project Links

- [API Documentation](README.md)
- [Setup Instructions](SETUP.md)
- [Architecture & Structure](PROJECT_STRUCTURE.md)
- [Contributing Guidelines](CONTRIBUTING.md)
- [GitHub Repository](https://github.com)

---

**Questions?** Check the detailed guides above or create an issue on GitHub.
