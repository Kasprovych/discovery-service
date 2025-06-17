# Use an official OpenJDK runtime as the base image
FROM openjdk:21-jdk

# Specify the JAR file (produced by Maven) to include in the image
ARG JAR_FILE=target/*.jar

# Copy the JAR file into the container
COPY ${JAR_FILE} app.jar

ENV PORT=8761

EXPOSE 8761

# Run the JAR file
ENTRYPOINT ["java","-jar","/app.jar"]



