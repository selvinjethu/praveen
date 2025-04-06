# Use Maven image to build the application
FROM maven:3.9.4-eclipse-temurin-21 AS build

WORKDIR /app
COPY pom.xml .
COPY src ./src

RUN mvn clean package -DskipTests

# Use lightweight JDK image to run the application
FROM eclipse-temurin:21-jdk-alpine

WORKDIR /app
RUN ls /app/
RUN ls /app/target/
COPY --from=build /app/target/my-web-app-1.0-SNAPSHOT.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
