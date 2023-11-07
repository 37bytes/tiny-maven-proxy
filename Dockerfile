FROM maven:3-openjdk-11 as build
WORKDIR /opt/
ADD . .
RUN mvn clean package

FROM openjdk:11-jre as run

WORKDIR /opt

COPY --from=build /opt/tiny-maven-proxy/target/tiny-maven-proxy.jar tiny-maven-proxy.jar

EXPOSE 5956

VOLUME /var/lib/maven

HEALTHCHECK \
 CMD curl --fail http://localhost:5956 || exit 1

ENTRYPOINT ["java",\
            "-Djava.security.egd=file:/dev/./urandom",\
            "-Dhttp.nonProxyHosts=localhost",\
            "-XX:+UnlockExperimentalVMOptions",\
            "-XX:+UseCGroupMemoryLimitForHeap",\
            "-XX:MaxRAMFraction=1",\
            "-jar",\
            "tiny-maven-proxy.jar",\
            "--maven.dir", "/var/lib/maven",\
            "--mirror", "https://jcenter.bintray.com,https://repo1.maven.org/maven2,https://plugins.gradle.org/m2,https://m2.hh.ru/content/repositories/public-releases"\
]