FROM gradle:jdk14  AS builder

COPY  . /home/gradle/src
RUN  chown gradle:gradle -R /home/gradle/src
WORKDIR /home/gradle/src
RUN gradle build --no-daemon  --debug --stacktrace --scan

RUN gradle generateAvroJava


FROM openjdk:14-alpine

EXPOSE 8080

RUN mkdir /app

COPY --from=builder /home/gradle/src/build/libs/*.jar /app/application.jar

ENTRYPOINT ["java", "-XX:+UnlockExperimentalVMOptions", "-Djava.security.egd=file:/dev/./urandom","-jar","/app/application.jar"]
