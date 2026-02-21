# Contributing to Wallet API

## Getting Started for Contributors

### 1. Setup Development Environment

Follow the [SETUP.md](SETUP.md) guide to set up your local environment.

### 2. Clone and Create Branch

```bash
git clone <repository-url>
cd wallet-api
git checkout -b feature/your-feature-name
```

## Development Guidelines

### Code Style

- **Java**: Follow Google Java style guide
- **Formatting**: Use default IDE formatting (Eclipse/IntelliJ)
- **Comments**: Write clear comments for complex logic
- **Naming**: Use meaningful variable and method names

### Project Organization

Files should be organized by:
- **Feature/Layer**: controller, service, repository, entity, dto, exception
- **Package Naming**: `com.wallet.<layer>`
- **Class Naming**: Use clear, descriptive names

### Adding New Features

1. **Create Entity** (if needed)
   ```java
   @Entity
   @Table(name = "your_table")
   public class YourEntity { ... }
   ```

2. **Create Migration**
   ```xml
   <!-- src/main/resources/db/changelog/XXX-description.xml -->
   ```

3. **Create Repository** (if needed)
   ```java
   @Repository
   public interface YourRepository extends JpaRepository<YourEntity, UUID> { }
   ```

4. **Create Service Layer**
   ```java
   @Service
   @RequiredArgsConstructor
   public class YourService { ... }
   ```

5. **Create Controller Endpoint** (if needed)
   ```java
   @RestController
   @RequestMapping("/api/v1/your-endpoint")
   public class YourController { ... }
   ```

6. **Write Tests**
   - Unit tests with mocks
   - Integration tests with H2
   - Controller tests with MockMvc

### Testing Requirements

**All new features must include:**

1. **Unit Tests** - Mock dependencies
   ```java
   @ExtendWith(MockitoExtension.class)
   class YourServiceTest { }
   ```

2. **Integration Tests** - Real database (H2)
   ```java
   @SpringBootTest
   class YourIntegrationTest { }
   ```

3. **Controller Tests** - API endpoints
   ```java
   @SpringBootTest
   @AutoConfigureMockMvc
   class YourControllerTest { }
   ```

**Test Coverage Requirements:**
- Minimum 80% for new code
- All error paths must be tested
- Edge cases should be covered

### Running Tests

```bash
# All tests
mvn test

# Specific test class
mvn test -Dtest=WalletControllerTest

# With coverage report
mvn test jacoco:report
```

## Commit Guidelines

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: A new feature
- `fix`: A bug fix
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `docs`: Documentation updates
- `chore`: Build, dependencies, configuration

**Scope:** The component being modified (controller, service, repository, etc.)

**Examples:**
```
feat(wallet-service): add transaction history
fix(error-handler): improve error messages
test(wallet-controller): add integration tests
```

### Commit Best Practices

- Commit frequently with logical units
- Write clear, descriptive messages
- Reference issues/PRs when relevant
- Don't mix refactoring with feature changes

## Pull Request Process

### Before Creating PR

1. **Update from main**
   ```bash
   git checkout main
   git pull origin main
   git rebase main your-branch
   ```

2. **Run all tests**
   ```bash
   mvn clean test
   ```

3. **Build application**
   ```bash
   mvn clean package
   ```

4. **Check code quality**
   - No warnings in IDE
   - No code duplications
   - Proper error handling

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Related Issues
Closes #(issue number)

## Testing Done
- [ ] Unit tests
- [ ] Integration tests
- [ ] Manual testing

## Checklist
- [ ] Code follows project style
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] No new warnings introduced
```

### PR Review Criteria

- Code follows project guidelines
- Tests are comprehensive
- Database migrations are included
- Documentation is updated
- No breaking changes (unless approved)

## Database Changes

### Adding New Table

1. **Create migration file**
   ```xml
   <!-- src/main/resources/db/changelog/XXX-add-table.xml -->
   <databaseChangeLog>
       <changeSet id="XXX-add-table" author="username">
           <createTable tableName="your_table">
               <!-- columns -->
           </createTable>
       </changeSet>
   </databaseChangeLog>
   ```

2. **Update master changelog**
   ```xml
   <include file="db/changelog/XXX-add-table.xml"/>
   ```

3. **Never alter existing migrations** - Create new ones for changes
4. **Test migrations locally**
   ```bash
   docker-compose down -v
   docker-compose up
   docker-compose logs -f postgres
   ```

## Configuration Changes

### Adding New Environment Variable

1. **Update .env.example**
   ```env
   NEW_VARIABLE=default_value
   ```

2. **Update application.yml**
   ```yaml
   myconfig:
      setting: ${NEW_VARIABLE:default}
   ```

3. **Document in SETUP.md**

### Changing Default Configuration

- Only change defaults if widely applicable
- For service-specific config, use application profiles
- Always maintain backward compatibility

## Dependencies

### Adding New Dependency

1. **Research thoroughly** - Is there a better alternative?
2. **Check for conflicts** - Run `mvn dependency:tree`
3. **Add to pom.xml**
4. **Run `mvn clean test`** to verify compatibility
5. **Update SETUP.md** if it affects setup

### Removing Dependencies

1. **Ensure it's not used** - Search codebase
2. **Run tests** - `mvn clean test`
3. **Update pom.xml**
4. **Verify build** - `mvn clean package`

## Documentation

### README.md
- API endpoints and examples
- Configuration options
- Troubleshooting

### SETUP.md
- Installation instructions
- Configuration steps
- Deployment guide

### JavaDoc
- Public APIs must have JavaDoc
- Describe parameters and return values
- Include examples for complex methods

```java
/**
 * Performs a wallet operation (deposit or withdraw).
 *
 * @param request the operation request containing walletId, operationType, and amount
 * @return the updated wallet response
 * @throws WalletNotFoundException if wallet doesn't exist
 * @throws InsufficientFundsException if withdrawal exceeds balance
 */
public WalletResponse processOperation(WalletOperationRequest request) { ... }
```

## Code Review Checklist

- [ ] Code follows Java style guidelines
- [ ] All tests pass
- [ ] Code coverage maintained or improved
- [ ] No code duplication
- [ ] Error handling is complete
- [ ] Database migrations are correct
- [ ] Documentation is updated
- [ ] Configuration changes documented
- [ ] No security vulnerabilities
- [ ] Performance implications considered

## Performance Considerations

When making changes, consider:

1. **Database queries** - Are indexes used?
2. **Caching** - Should we cache results?
3. **Connection pooling** - Is pool size adequate?
4. **Transaction isolation** - Correct isolation level?
5. **Batch operations** - Should we batch inserts/updates?

## Security Guidelines

1. **Input Validation** - Always validate user input
2. **SQL Injection** - Use parameterized queries (JPA handles this)
3. **Error Messages** - Don't expose internal details
4. **Logging** - Don't log sensitive data
5. **Secrets** - Use environment variables, not code

## Common Issues and Solutions

### Build Fails
```bash
# Clear Maven cache
mvn clean

# Update dependencies
mvn dependency:resolve
```

### Database Lock
```bash
# Restart PostgreSQL
docker-compose restart postgres
```

### Tests Fail in CI but Pass Locally
- Check environment variables
- Verify test isolation
- Check for timing issues
- Review system dependencies

### Application Won't Start
- Check logs: `docker-compose logs wallet-api`
- Verify database is accessible
- Check for port conflicts
- Verify environment configuration

## Getting Help

- **Issues**: Check existing issues or create new one
- **Discussions**: Use GitHub discussions for questions
- **Email**: Contact maintainers for complex issues

## Code of Conduct

- Be respectful and inclusive
- No harassment or discrimination
- Constructive criticism welcomed
- Help junior developers learn

## License

By contributing, you agree that your contributions will be licensed under the project's license.
