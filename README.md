# OpenTelemetry-enabled Fuseki

This builds a Docker image that runs Fuseki with the OpenTelemetry Java agent setup.
To test that image, this repository includes a docker-compose stack with:

- Two Fuseki serving respectively `data/persons.nt` and `data/relations.nt` on http://localhost:3030/ and http://localhost:3031
- `opentelemetry-collector` to receive traces and metrics via OTLP
- A Jaeger "all in one" service to ingest and visualize traces: http://localhost:16686/
- A Prometheus instance scraping the exposed metrics: http://localhost:9090
- An Elasticsearch-Filebeat-Kibana setup that ingests logs from the whole stack. Kibana is running on http://localhost:5601/

## Sample federated query

Run this query on [`fuseki-persons`](http://localhost:3030/dataset.html?tab=query&ds=/ds):

```sparql
PREFIX schema: <http://schema.org/>

SELECT ?p ?givenName ?familyName ?additionalName (COUNT(?p) as ?relationships) WHERE {
  ?p a schema:Person ;
    schema:givenName ?givenName ;
    schema:familyName ?familyName .

  OPTIONAL {
    ?p schema:additionalName ?additionalName .

    SERVICE <http://fuseki-relations:3030/ds> {
      ?p schema:knows [] .
    }
  }
}
GROUP BY ?p ?givenName ?familyName ?additionalName
```

Check the resulting traces [in Jaeger](http://localhost:16686/search?operation=HTTP%20GET&service=fuseki-persons).
