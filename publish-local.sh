#!/bin/bash

# curl -X POST "http://localhost:3030/ds/update" \
#     --data "DROP ALL" \
#     --header "Content-Type: application/sparql-update"

for file in build/data/*.ttl
do
    curl -X PUT "http://localhost:3030/ds/data" \
    --data-binary @$file \
    --header "Content-Type: application/turtle" \
    --url-query "graph=http://fdri.ceh.ac.uk/graph/${file#"build/"}"
    if [ -n "${ACTIVITY_ID}" ]
    then
        curl -X POST "http://localhost:3030/ds/data" \
        --data "<http://fdri.ceh.ac.uk/graph/${file#"build/"}> <http://fdri.ceh.ac.uk/vocab/metadata/wasModifiedBy> <http://fdri.ceh.ac.uk/id/activity/${ACTIVITY_ID}> ." \
        --header "Content-Type: application/turtle" \
        --url-query "graph=http://fdri.ceh.ac.uk/graph/${file#"build/"}"
    fi
done

curl -X PUT "http://localhost:3030/ds/data" \
    --data-binary @ontology/owl/fdri-metadata.ttl \
    --header "Content-Type: application/turtle" \
    --url-query "graph=http://fdri.ceh.ac.uk/graph/ontology"

curl -X POST "http://localhost:3030/ds/update" \
    --data-binary @sample_data/dependencies.su \
    --header "Content-Type: application/sparql-update"