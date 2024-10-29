# 1단계: 빌드
FROM gradle:jdk17 AS build

WORKDIR /home/gradle/project

COPY build.gradle settings.gradle /home/gradle/project/
COPY src /home/gradle/project/src

RUN gradle clean build -x test --no-daemon

# 2단계: 실행
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

COPY --from=build /home/gradle/project/build/libs/websocket-demo-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
