FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Install dependencies
RUN apk add --no-cache curl

# Copy the built JAR from Maven
COPY target/wallet-api-1.0.0.jar app.jar

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
