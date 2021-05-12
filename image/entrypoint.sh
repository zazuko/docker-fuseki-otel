#!/bin/sh
## Licensed under the terms of http://www.apache.org/licenses/LICENSE-2.0

exec "$JAVA_HOME/bin/java"               \
  $JAVA_OPTIONS                          \
  -javaagent:"${FUSEKI_DIR}/${OTEL_JAR}" \
  -Xshare:off                            \
  -jar "${FUSEKI_DIR}/${FUSEKI_JAR}"     \
  "$@"
