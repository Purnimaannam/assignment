# Project Structure

## Overview

```
wallet-api/
├── src/
│   ├── main/
│   │   ├── java/com/wallet/
│   │   │   ├── WalletApplication.java          # Main Spring Boot application
│   │   │   ├── config/
│   │   │   │   └── RetryConfig.java            # Retry configuration for optimistic locking
│   │   │   ├── controller/
│   │   │   │   └── WalletController.java       # REST API endpoints
│   │   │   ├── service/
│   │   │   │   └── WalletService.java          # Business logic and wallet operations
│   │   │   ├── repository/
│   │   │   │   └── WalletRepository.java       # JPA repository for Wallet entity
│   │   │   ├── entity/
│   │   │   │   └── Wallet.java                 # JPA entity with version for optimistic locking
│   │   │   ├── enums/
│   │   │   │   └── OperationType.java          # DEPOSIT, WITHDRAW operations
│   │   │   ├── dto/
│   │   │   │   ├── WalletOperationRequest.java # Request DTO
│   │   │   │   ├── WalletResponse.java         # Response DTO
│   │   │   │   └── ErrorResponse.java          # Error response DTO
│   │   │   └── exception/
│   │   │       ├── WalletNotFoundException.java # 404 exception
│   │   │       ├── InsufficientFundsException.java # 400 exception
│   │   │       ├── InvalidOperationException.java  # 400 exception
│   │   │       └── GlobalExceptionHandler.java    # Global exception handling
│   │   └── resources/
│   │       ├── application.yml                 # Main application configuration
│   │       └── db/
│   │           └── changelog/
│   │               ├── db.changelog-master.xml # Liquibase master changelog
│   │               └── 001-initial-schema.xml  # Initial database schema migration
│   │
│   └── test/
│       ├── java/com/wallet/
│       │   ├── WalletIntegrationTest.java      # Integration tests with H2
│       │   ├── controller/
│       │   │   └── WalletControllerTest.java   # REST API endpoint tests
│       │   └── service/
│       │       └── WalletServiceTest.java      # Business logic unit tests
│       └── resources/
│           └── application.yml                 # Test configuration with H2
│
├── pom.xml                                      # Maven configuration
├── Dockerfile                                   # Docker image for application
├── docker-compose.yml                          # Docker Compose orchestration
├── .env                                         # Environment variables (dev defaults)
├── .env.example                                 # Environment variables template
├── .gitignore                                   # Git ignore rules
├── README.md                                    # API documentation
├── SETUP.md                                     # Setup and deployment guide
├── PROJECT_STRUCTURE.md                         # This file
├── setup.sh                                     # Setup script for Linux/Mac
├── setup.bat                                    # Setup script for Windows
├── load-test.sh                                 # Load testing script (Linux/Mac)
├── load-test.ps1                                # Load testing script (Windows)
└── .github/
    └── workflows/
        └── build.yml                            # GitHub Actions CI/CD pipeline
```

## Directory Descriptions

### `/src/main/java/com/wallet/`
Contains all application source code organized by layers:
- **controller**: REST API endpoints
- **service**: Business logic and transaction handling
- **repository**: Data access layer (JPA)
- **entity**: JPA entities (database models)
- **dto**: Data Transfer Objects (request/response models)
- **exception**: Custom exceptions and global exception handler
- **enums**: Enumerations (OperationType)
- **config**: Spring configuration classes

### `/src/main/resources/`
Configuration files and database migrations:
- **application.yml**: Spring Boot configuration
- **db/changelog/**: Liquibase migration files

### `/src/test/`
Test code organized by layer:
- **WalletIntegrationTest**: End-to-end tests with real database (H2)
- **controller/WalletControllerTest**: REST API endpoint tests
- **service/WalletServiceTest**: Unit tests for business logic

### Root Level Files
- **pom.xml**: Maven project configuration with dependencies
- **Dockerfile**: Multi-stage Docker build configuration
- **docker-compose.yml**: Service orchestration (app + database)
- **.env**: Environment variables for local development
- **README.md**: Complete API and feature documentation
- **SETUP.md**: Detailed setup and deployment instructions

## Key Components

### 1. Wallet Entity
```java
@Entity
@Table(name = "wallets")
public class Wallet {
    @Id private UUID walletId;
    @Column private BigDecimal balance;
    @Version private Long version;  // For optimistic locking
    @Column private LocalDateTime createdAt;
    @Column private LocalDateTime updatedAt;
}
```

### 2. WalletService
- Handles DEPOSIT and WITHDRAW operations
- Implements optimistic locking with retry mechanism
- Validates business rules (sufficient funds, wallet exists)
- Uses @Retryable annotation for concurrency handling

### 3. WalletController
- REST API with two endpoints:
  - `POST /api/v1/wallet` - Process operations
  - `GET /api/v1/wallets/{walletId}` - Get balance
- Input validation using @Valid annotations
- Returns proper HTTP status codes

### 4. GlobalExceptionHandler
Handles all exceptions with appropriate HTTP responses:
- 404: WalletNotFoundException
- 400: InsufficientFundsException, ValidationException, InvalidJsonException
- 500: Unexpected errors (logged but not exposed to client)

### 5. Database Schema
PostgreSQL with Liquibase migrations:
- Single `wallets` table with UUID primary key
- BigDecimal balance field (19,2 precision)
- Optimistic locking via version column
- Indexes on wallet_id and updated_at

### 6. Configuration & Deployment
- Environment-based configuration (.env)
- Docker image with health checks
- Docker Compose with PostgreSQL
- GitHub Actions CI/CD pipeline

## Data Flow

### Deposit/Withdraw Operation
1. Client sends POST request to `/api/v1/wallet`
2. Controller validates JSON and calls WalletService.processOperation()
3. Service fetches wallet from database
4. Service validates business rules
5. Service updates balance and saves wallet
6. If OptimisticLockingFailureException occurs, retry (max 3 times with backoff)
7. Return updated balance to client

### Get Balance
1. Client sends GET request to `/api/v1/wallets/{walletId}`
2. Controller calls WalletService.getWalletBalance()
3. Service fetches wallet from database
4. Return balance to client

## Testing Strategy

### Unit Tests (WalletServiceTest)
- Mock repository
- Test all operation types
- Test error scenarios
- ~50% of code coverage

### Integration Tests (WalletIntegrationTest)
- Real database (H2 in-memory)
- Full request/response flow
- Concurrent operations
- ~30% additional coverage

### API Tests (WalletControllerTest)
- MockMvc for HTTP testing
- Test all endpoints
- Test all error responses
- Validation testing

## Performance Characteristics

- **Concurrency**: Optimistic locking handles 1000+ RPS per wallet
- **Connection Pool**: HikariCP with 20 connections (configurable)
- **Transaction Isolation**: READ_COMMITTED to prevent deadlocks
- **Retry Strategy**: 3 attempts with 10ms, 20ms, 40ms delays
- **Database Indexes**: wallet_id and updated_at for query performance

## Security Considerations

1. **Input Validation**: All inputs validated via @Valid annotations
2. **No SQL Injection**: Parameterized queries via JPA
3. **Error Messages**: Don't expose internal details
4. **Transaction Safety**: Optimistic locking prevents race conditions
5. **No Authentication/Authorization**: Can be added as needed

## Extending the Application

### Adding New Operation Types
1. Add to OperationType enum
2. Add logic to WalletService.processOperation()
3. Add tests to WalletServiceTest
4. Update API documentation

### Adding User Management
1. Create User entity and repository
2. Add user_id to Wallet entity
3. Update migration files
4. Add authorization to controller

### Adding Audit Trail
1. Create Transaction entity
2. Log all operations to transactions table
3. Add new endpoint to query transaction history
4. Update migration files
