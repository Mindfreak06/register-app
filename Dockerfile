# Use a lightweight Java 21 runtime
FROM eclipse-temurin:21-jre-alpine

# Create app directory and run as non-root user for safety
WORKDIR /app
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Allow CI to override the JAR filename if needed
ARG JAR_FILE=target/register-app-1.0-SNAPSHOT.jar

# Copy the built JAR from the Maven target directory into the image
COPY ${JAR_FILE} /app/app.jar

# Expose the port your application listens on (adjust if needed)
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
