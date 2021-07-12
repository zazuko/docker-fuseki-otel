#!/bin/sh

export OTEL_RESOURCE_ATTRIBUTES="container.id=$(hostname),$OTEL_RESOURCE_ATTRIBUTES"

if ! [ -z "$ADMIN_PASSWORD" ]; then
  envsubst '$ADMIN_PASSWORD' \
    < "${FUSEKI_HOME}/shiro.ini.tmpl" \
    > "${FUSEKI_BASE}/shiro.ini"
fi

exec "$JAVA_HOME/bin/java"                \
  $JAVA_OPTIONS                           \
  -javaagent:"${FUSEKI_HOME}/${OTEL_JAR}" \
  -Xshare:off                             \
  -Dlog4j.configurationFile="file:${FUSEKI_HOME}/log4j2.properties" \
  -jar "${FUSEKI_HOME}/${FUSEKI_JAR}"     \
  "$@"
