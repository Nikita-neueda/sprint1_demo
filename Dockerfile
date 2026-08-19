FROM eclipse-temurin:21-jre-alpine
WORKDIR ./app
COPY /var/lib/jenkins/workspace/Docker_build/starter/target/team-skeleton-*.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
