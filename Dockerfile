# ================================
# Stage 1: Build with Maven
# ================================
FROM maven:3.9-eclipse-temurin-21 AS build

WORKDIR /app

# Copy pom and download dependencies first (cache layer)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code and database
COPY src ./src
COPY fashion_store.db .

# Build the WAR file
RUN mvn clean package -DskipTests

# ================================
# Stage 2: Run on Tomcat
# ================================
FROM tomcat:10.1-jdk21

# Remove default Tomcat ROOT app
RUN rm -rf /usr/local/tomcat/webapps/ROOT

# Copy built WAR as ROOT (so app runs at /)
COPY --from=build /app/target/fashion-store-0.0.1-SNAPSHOT.war /usr/local/tomcat/webapps/ROOT.war

# Copy SQLite DB to Tomcat working directory
COPY --from=build /app/fashion_store.db /usr/local/tomcat/fashion_store.db

# Expose port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
