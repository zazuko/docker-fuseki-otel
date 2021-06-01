ARG OPENJDK_VERSION=16
ARG ALPINE_VERSION=3.13
ARG JENA_VERSION=4.0.0
ARG JENA_GEOSPARQL_VERSION=4.0.0
ARG OTEL_VERSION=1.1.0

ARG FUSEKI_HOME=/opt/fuseki
ARG FUSEKI_BASE=/fuseki
ARG FUSEKI_JAR=fuseki-server.jar
ARG GEOSPARQL_JAR=jena-fuseki-geosparql.jar
ARG OTEL_JAR=opentelemetry-javaagent-all.jar
ARG JAVA_MINIMAL=/opt/java-minimal

## Build minimal java environment
FROM openjdk:${OPENJDK_VERSION}-alpine${ALPINE_VERSION} AS base

ARG JAVA_MINIMAL
ARG JENA_VERSION
ARG JENA_GEOSPARQL_VERSION
ARG FUSEKI_HOME
ARG FUSEKI_JAR
ARG GEOSPARQL_JAR
ARG OTEL_VERSION
ARG OTEL_JAR
ARG REPO=https://repo1.maven.org/maven2
ARG ARTIFACT=apache-jena-fuseki-${JENA_VERSION}
ARG ZIP_URL=${REPO}/org/apache/jena/apache-jena-fuseki/${JENA_VERSION}/${ARTIFACT}.zip
ARG GEOSPARQL_JAR_URL="${REPO}/org/apache/jena/jena-fuseki-geosparql/${JENA_GEOSPARQL_VERSION}/jena-fuseki-geosparql-${JENA_GEOSPARQL_VERSION}.jar"

RUN apk add --no-cache curl binutils

WORKDIR $FUSEKI_HOME

# Get the webapp folder and the jar from the full zip
RUN wget "$ZIP_URL" && \
    unzip ${ARTIFACT}.zip && \
    mv ${ARTIFACT}/webapp ${ARTIFACT}/${FUSEKI_JAR} ./ && \
    rm -r ${ARTIFACT}/ ${ARTIFACT}.zip

RUN wget "${GEOSPARQL_JAR_URL}" -O "${GEOSPARQL_JAR}"
RUN wget https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v${OTEL_VERSION}/${OTEL_JAR}

ARG JDEPS_EXTRA="jdk.crypto.cryptoki,jdk.crypto.ec"
RUN \
    JDEPS="$(jdeps --multi-release base --print-module-deps --ignore-missing-deps ${FUSEKI_JAR} ${OTEL_JAR} ${GEOSPARQL_JAR})"  && \
    jlink \
    --compress 2 --strip-debug --no-header-files --no-man-pages \
    --output "${JAVA_MINIMAL}" \
    --add-modules "${JDEPS},${JDEPS_EXTRA}"

## Build final runtime
FROM alpine:${ALPINE_VERSION}

ARG JENA_VERSION
ARG JAVA_MINIMAL
ARG FUSEKI_HOME
ARG FUSEKI_BASE
ARG FUSEKI_JAR
ARG OTEL_JAR
ARG GEOSPARQL_JAR

COPY --from=base ${JAVA_MINIMAL} ${JAVA_MINIMAL}
COPY --from=base ${FUSEKI_HOME} ${FUSEKI_HOME}

# Run as this user
# -H : no home directorry
# -D : no password
# -u : explicit UID
RUN adduser -H -D -u 1000 fuseki fuseki

ADD entrypoint.sh log4j2.properties ${FUSEKI_HOME}/

RUN mkdir -p ${FUSEKI_BASE}/databases && \
    chown -R fuseki $FUSEKI_BASE

# Default environment variables
ENV \
    JAVA_HOME=${JAVA_MINIMAL} \
    JAVA_OPTIONS="-Xmx2048m -Xms2048m" \
    JENA_VERSION=${JENA_VERSION} \
    FUSEKI_HOME="${FUSEKI_HOME}" \
    FUSEKI_BASE="${FUSEKI_BASE}" \
    FUSEKI_JAR="${FUSEKI_JAR}" \
    OTEL_JAR="${OTEL_JAR}" \
    GEOSPARQL_JAR="${GEOSPARQL_JAR}" \
    OTEL_TRACES_EXPORTER=none \
    OTEL_METRICS_EXPORTER=none

# Run as "fuseki" (explicit UID so "run as non-root" policies can be enforced)
USER 1000
WORKDIR $FUSEKI_BASE
EXPOSE 3030

# Keep this path in sync with $FUSEKI_HOME since ENTRYPOINT does not do
# buildarg expansion
ENTRYPOINT [ "/opt/fuseki/entrypoint.sh" ]
CMD []
