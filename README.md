# OpenTelemetry-enabled Fuseki

This builds a Docker image that runs Fuseki with the OpenTelemetry Java agent setup.
To test that image, this repository includes a docker-compose stack with:

- Two Fuseki serving respectively `data/persons.nt` and `data/relations.nt` on <http://localhost:3030/> and <http://localhost:3031>
- `opentelemetry-collector` to receive traces and metrics via OTLP
- A Jaeger "all in one" service to ingest and visualize traces: <http://localhost:16686/>
- A Prometheus instance scraping the exposed metrics: <http://localhost:9090>
- A Filebeat module that parses Fuseki logs
- An Elasticsearch-Filebeat-Kibana setup that ingests logs from the whole stack. Kibana is running on <http://localhost:5601/>
- A Grafana instance to visualize logs and traces: <http://localhost:3000/>

## Running

1. Clone the repository
2. Run `docker-compose up` from within the cloned repository

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

Check the logs [in Grafana](http://localhost:3000):

- Navigate to the [explore view](http://localhost:3000/explore)
- In the query builder at the top, under "Metric" select "Logs" instead of "Count"
- Unroll a log entry with a trace (basically anything else than the startup logs)
- Click on "Jaeger" to view the associated trace
