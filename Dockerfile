# Build stage
FROM maven:3.9.4-eclipse-temurin-21 AS build

WORKDIR /app
COPY pom.xml .
COPY src ./src

# Build the project and create fat jar
RUN mvn clean package -DskipTests

# Run stage
FROM eclipse-temurin:21-jdk-alpine

WORKDIR /app
COPY --from=build /app/target/my-web-app-1.0.0.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
