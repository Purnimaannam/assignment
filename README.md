# Wallet API

A high-performance REST API for managing wallet operations (deposits and withdrawals) with optimistic locking to handle concurrent transactions safely. Built with Spring Boot 3, PostgreSQL, and Docker.

## Features

- ✅ **REST API Endpoints**
  - `POST /api/v1/wallet` - Perform wallet operations (deposit/withdraw)
  - `GET /api/v1/wallets/{walletId}` - Get wallet balance

- ✅ **High Concurrency Handling**
  - Optimistic locking with version control to handle up to 1000+ RPS per wallet
  - Retry mechanism with exponential backoff for transient failures
  - Connection pooling with HikariCP

- ✅ **Error Handling**
  - No 5XX errors for client-side issues (invalid JSON, validation errors, wallet not found)
  - Proper HTTP status codes and error messages
  - Graceful handling of business logic errors

- ✅ **Database**
  - PostgreSQL with Liquibase migrations
  - Transaction isolation level: READ_COMMITTED
  - Automatic schema validation on startup

- ✅ **Containerization**
  - Docker image for the application
  - Docker Compose for orchestrating application + database
  - Environment-based configuration

- ✅ **Testing**
  - Integration tests for REST controllers
  - Unit tests for business logic
  - Test coverage for all error scenarios

## Technology Stack

- **Java 17**
- **Spring Boot 3.2.0**
- **Spring Data JPA**
- **PostgreSQL 15**
- **Liquibase 4.24.0**
- **JUnit 5**
- **Mockito**
- **Docker & Docker Compose**

## Getting Started

### Prerequisites

- Java 17 or higher
- Maven 3.6.0 or higher
- Docker and Docker Compose
- PostgreSQL 15 (if running locally without Docker)

### Building the Application

```bash
# Clone the repository
cd wallet-api

# Build with Maven
mvn clean package

# Run tests
mvn test
```

### Running with Docker Compose (Recommended)

```bash
# Create .env file from template (or use existing)
cp .env.example .env

# Start services
docker-compose up -d

# Verify services are running
docker-compose ps

# View logs
docker-compose logs -f wallet-api
docker-compose logs -f postgres

# Stop services
docker-compose down
```

### Running Locally

**Prerequisites:**
- PostgreSQL 15 running and accessible
- Update `application.yml` with your database credentials

```bash
# Run the application
mvn spring-boot:run

# Or run the JAR directly
java -jar target/wallet-api-1.0.0.jar
```

## Configuration

### Environment Variables

All configuration can be set via environment variables. See `.env.example` for complete list:

- `DB_HOST` - Database hostname (default: localhost)
- `DB_PORT` - Database port (default: 5432)
- `DB_NAME` - Database name (default: walletdb)
- `DB_USER` - Database user (default: postgres)
- `DB_PASSWORD` - Database password (default: postgres)
- `SERVER_PORT` - Application port (default: 8080)
- `LOG_LEVEL` - Logging level (default: INFO)
- `DB_MAX_POOL_SIZE` - Connection pool size (default: 20)
- `DB_MIN_IDLE` - Minimum idle connections (default: 5)

## API Endpoints

### 1. Wallet Operation (Deposit/Withdraw)

**Request:**
```
POST /api/v1/wallet
Content-Type: application/json

{
  "walletId": "550e8400-e29b-41d4-a716-446655440000",
  "operationType": "DEPOSIT",
  "amount": 1000.00
}
```

**Successful Response (200 OK):**
```json
{
  "walletId": "550e8400-e29b-41d4-a716-446655440000",
  "balance": 2000.00,
  "updatedAt": "2024-02-21T10:30:45.123456"
}
```

**Error Responses:**
- `400 BAD REQUEST` - Invalid JSON, missing fields, insufficient funds
- `404 NOT FOUND` - Wallet doesn't exist

### 2. Get Wallet Balance

**Request:**
```
GET /api/v1/wallets/550e8400-e29b-41d4-a716-446655440000
```

**Successful Response (200 OK):**
```json
{
  "walletId": "550e8400-e29b-41d4-a716-446655440000",
  "balance": 2000.00,
  "updatedAt": "2024-02-21T10:30:45.123456"
}
```

**Error Response (404 NOT FOUND):**
```json
{
  "error": "WALLET_NOT_FOUND",
  "message": "Wallet not found: 550e8400-e29b-41d4-a716-446655440000",
  "status": 404,
  "timestamp": "2024-02-21T10:31:00"
}
```

## Testing

### Run All Tests

```bash
mvn test
```

### Run Specific Test Class

```bash
mvn test -Dtest=WalletControllerTest
mvn test -Dtest=WalletServiceTest
```

### Test Coverage

The test suite includes:
- **Happy Path Tests**: Successful deposits, withdrawals, and balance queries
- **Error Scenarios**: 
  - Wallet not found (404)
  - Insufficient funds (400)
  - Invalid JSON (400)
  - Missing required fields (400)
  - Negative amounts (400)
- **Concurrency Tests**: Optimistic locking and retry behavior

## Concurrency Handling

The application uses **optimistic locking** to handle high-concurrency scenarios:

1. Each wallet has a `version` field that increments with every update
2. When updating a wallet, Spring JPA verifies the version hasn't changed
3. If a conflict occurs (OptimisticLockingFailureException), the operation is retried
4. Retry mechanism uses exponential backoff: initial delay 10ms, multiplier 2, max 3 attempts

This approach handles 1000+ RPS per wallet without blocking other transactions.

## Database Schema

### Wallets Table
```sql
CREATE TABLE wallets (
    wallet_id UUID PRIMARY KEY,
    balance NUMERIC(19,2) NOT NULL,
    version BIGINT,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);
```

**Indexes:**
- Primary key on `wallet_id`
- Index on `updated_at` for query optimization
- Version column for optimistic locking

All schema changes are managed via Liquibase migrations in `src/main/resources/db/changelog/`.

## Health Check

The application provides a health endpoint:

```bash
curl http://localhost:8080/actuator/health
```

Response:
```json
{
  "status": "UP",
  "components": {
    "db": {
      "status": "UP"
    },
    "diskSpace": {
      "status": "UP"
    }
  }
}
```

## Performance Considerations

1. **Connection Pooling**: HikariCP with configurable pool size (default: 20)
2. **Optimistic Locking**: No pessimistic locks, better for read-heavy workloads
3. **Batch Operations**: Enabled in Hibernate configuration
4. **Transaction Isolation**: READ_COMMITTED to prevent deadlocks
5. **Retry Mechanism**: Handles transient failures gracefully

## Troubleshooting

### Database Connection Refused

```
Error: Connection refused
```

**Solution:**
- Ensure PostgreSQL is running: `docker-compose logs postgres`
- Check `.env` file database credentials
- Wait for PostgreSQL to be ready (healthcheck should pass)

### Cannot Acquire Lock

```
Error: OptimisticLockingFailureException
```

**Solution:**
- This is expected in high-concurrency scenarios
- Application automatically retries (max 3 times)
- If persistently failing, check for database performance issues

### Migrations Not Applied

```
Error: Liquibase table not found
```

**Solution:**
- Ensure `liquibase.enabled: true` in `application.yml`
- Check `src/main/resources/db/changelog/db.changelog-master.xml`
- View logs: `docker-compose logs wallet-api | grep Liquibase`

## License

This project is provided as-is for evaluation purposes.

## Contact

For issues or questions, please create an issue in the repository or contact the development team.
