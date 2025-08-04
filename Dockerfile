# --- build stage with Maven and Java 21 ---
FROM maven:3.9.4-eclipse-temurin-21 AS build

WORKDIR /app

# Cache dependencies
COPY pom.xml .
RUN mvn -B dependency:go-offline

# Copy source and build the fat jar
COPY src ./src
RUN mvn -B clean package -DskipTests

# --- runtime stage ---
FROM eclipse-temurin:21-jre-jammy

WORKDIR /app

# Allow Spring to pick up Render's PORT if provided via environment or application.yaml
COPY --from=build /app/target/first-deployment-0.0.1.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
