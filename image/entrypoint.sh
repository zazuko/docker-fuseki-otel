#!/bin/sh

set -e

export OTEL_RESOURCE_ATTRIBUTES="container.id=$(hostname),$OTEL_RESOURCE_ATTRIBUTES"
export JAVA_OPTS="${JAVA_OPTS} -javaagent:${OTEL_HOME}/${OTEL_JAR} -Xshare:off"

if ! [ -z "$ADMIN_PASSWORD" ]; then
  envsubst '$ADMIN_PASSWORD' \
    < "${FUSEKI_HOME}/shiro.ini.tmpl" \
    > "${FUSEKI_BASE}/shiro.ini"
fi

exec $@
