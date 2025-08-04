# --- build stage ---
FROM eclipse-temurin:21-jdk-jammy AS build

WORKDIR /app

# Cache Maven dependencies by copying only the pom first
COPY pom.xml .
RUN mkdir -p src && mvn -B -f pom.xml dependency:go-offline

# Copy source and build
COPY src ./src
RUN mvn -B -f pom.xml clean package -DskipTests

# --- runtime stage ---
FROM eclipse-temurin:21-jre-jammy

WORKDIR /app

# If Render injects PORT, Spring can bind to it if configured; fallback to 8080
# (You can also set server.port via application.yaml or env var)
ENV SPRING_MAIN_ALLOW_BEAN_DEFINITION_OVERRIDING=true

COPY --from=build /app/target/first-deployment-0.0.1.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
