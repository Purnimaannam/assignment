# Setup and Deployment Guide

## Prerequisites Installation

### Windows

#### 1. Install Java 17
- **Option A: Using Chocolatey (Recommended)**
  ```powershell
  choco install openjdk17
  ```
- **Option B: Manual Installation**
  - Download from [Eclipse Temurin](https://adoptium.net/download)
  - Install and note the installation path
  - Add to PATH: `C:\Program Files\Eclipse Adoptium\jdk-17.x.x\bin`

#### 2. Install Maven
- **Option A: Using Chocolatey**
  ```powershell
  choco install maven
  ```
- **Option B: Manual Installation**
  - Download from [Apache Maven](https://maven.apache.org/download.cgi)
  - Extract to a directory (e.g., `C:\apache-maven`)
  - Add to PATH: `C:\apache-maven\bin`
  - Verify: `mvn -v`

#### 3. Install Docker Desktop
- Download from [Docker Official Site](https://www.docker.com/products/docker-desktop)
- Install and start Docker Desktop
- Verify: `docker --version`

#### 4. Verify Installation
```powershell
java -version
mvn -version
docker --version
docker-compose --version
```

### Linux (Ubuntu/Debian)

```bash
# Update packages
sudo apt-get update

# Install Java 17
sudo apt-get install -y openjdk-17-jdk

# Install Maven
sudo apt-get install -y maven

# Install Docker
sudo apt-get install -y docker.io
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installations
java -version
mvn -version
docker --version
docker-compose --version
```

### macOS

```bash
# Using Homebrew
brew install openjdk@17
brew install maven
brew install docker
brew install docker-compose

# Verify installations
java -version
mvn -version
docker --version
docker-compose --version
```

## Local Development Setup

### 1. Clone Repository
```bash
cd /path/to/project
git clone <repository-url>
cd wallet-api
```

### 2. Copy Environment Configuration
```bash
cp .env.example .env
```

### 3. Build the Application
```bash
mvn clean package -DskipTests
```

### 4. Run Tests (Optional)
```bash
mvn test
```

### 5. Start Docker Containers
```bash
docker-compose up -d
```

### 6. Verify Services
```bash
# Check running containers
docker-compose ps

# Check application health
curl http://localhost:8080/actuator/health

# View application logs
docker-compose logs -f wallet-api
```

## Running with Docker Compose

### Start Services
```bash
docker-compose up -d
```

### Stop Services
```bash
docker-compose down
```

### Remove All Data
```bash
docker-compose down -v
```

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f wallet-api
docker-compose logs -f postgres
```

## Configuration

### Environment Variables

Edit `.env` file to customize:

```env
# Database
DB_HOST=postgres
DB_PORT=5432
DB_NAME=walletdb
DB_USER=postgres
DB_PASSWORD=postgres
DB_MAX_POOL_SIZE=20

# Application
SERVER_PORT=8080
LOG_LEVEL=INFO
```

**Note:** After changing `.env`, restart containers:
```bash
docker-compose down
docker-compose up -d
```

## Testing the API

### Create a Test Wallet
```bash
# Create wallet with initial balance
curl -X POST http://localhost:8080/api/v1/wallet \
  -H "Content-Type: application/json" \
  -d '{
    "walletId": "550e8400-e29b-41d4-a716-446655440000",
    "operationType": "DEPOSIT",
    "amount": 1000.00
  }'
```

### Get Wallet Balance
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

## Running Load Tests

### Using the Provided Scripts

#### On Linux/macOS
```bash
chmod +x load-test.sh
./load-test.sh 100 10
# Arguments: [number of requests] [concurrent requests]
```

#### On Windows (PowerShell)
```powershell
.\load-test.ps1 -NumRequests 100 -NumConcurrent 10
```

## Troubleshooting

### Docker Connection Error
```
Error: Cannot connect to Docker daemon
```
**Solution:** Ensure Docker Desktop is running

### Port Already in Use
```
Error: port 8080 is already in use
```
**Solution:** Change port in `.env`:
```env
SERVER_PORT=8081
```
Then restart: `docker-compose restart`

### Database Connection Error
```
Error: Connection refused at localhost:5432
```
**Solution:** 
- Check if postgres is running: `docker-compose ps`
- View logs: `docker-compose logs postgres`
- Restart: `docker-compose up -d postgres`

### Application Won't Start
```
Error: Liquibase changeset not found
```
**Solution:**
- Check migration files exist: `src/main/resources/db/changelog/`
- View logs: `docker-compose logs wallet-api`
- Restart: `docker-compose restart wallet-api`

### Build Fails
```
Error: Maven is not installed
```
**Solution:** Install Maven following prerequisites section above

## Production Deployment

### Building Docker Image
```bash
mvn clean package -DskipTests
docker build -t wallet-api:1.0.0 .
```

### Pushing to Registry
```bash
# Tag the image
docker tag wallet-api:1.0.0 your-registry/wallet-api:1.0.0

# Push to registry
docker push your-registry/wallet-api:1.0.0
```

### Environment-Specific Configuration
```bash
# Development
export LIQUIBASE_CONTEXT=dev
docker-compose up

# Production
export LIQUIBASE_CONTEXT=prod
docker-compose up
```

## Monitoring and Maintenance

### Health Check Endpoint
```bash
curl http://localhost:8080/actuator/health
```

### Metrics Endpoint
```bash
curl http://localhost:8080/actuator/metrics
```

### Database Backup
```bash
docker-compose exec postgres pg_dump -U postgres walletdb > backup.sql
```

### Database Restore
```bash
cat backup.sql | docker-compose exec -T postgres psql -U postgres walletdb
```

## Next Steps

1. Review the [README.md](README.md) for API documentation
2. Run the test suite: `mvn test`
3. Explore the codebase in `src/main/java/com/wallet/`
4. Customize configuration in `src/main/resources/application.yml`
