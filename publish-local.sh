#!/bin/bash

curl -X POST "http://localhost:3030/ds/update" \
    --data "DROP ALL" \
    --header "Content-Type: application/sparql-update"

for file in build/data/*.ttl
do
    curl -X PUT "http://localhost:3030/ds/data" \
    --data-binary @$file \
    --header "Content-Type: application/turtle" \
    --url-query "graph=http://fdri.ceh.ac.uk/graph/${file#"build/"}"
done

curl -X PUT "http://localhost:3030/ds/data" \
    --data-binary @ontology/owl/fdri-metadata.ttl \
    --header "Content-Type: application/turtle" \
    --url-query "graph=http://fdri.ceh.ac.uk/graph/ontology"

curl -X POST "http://localhost:3030/ds/update" \
    --data-binary @sample_data/dependencies.su \
    --header "Content-Type: application/sparql-update"