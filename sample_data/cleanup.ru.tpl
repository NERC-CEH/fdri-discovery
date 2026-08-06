PREFIX  dct:  <http://purl.org/dc/terms/>
PREFIX  fdri: <http://fdri.ceh.ac.uk/vocab/metadata/>
PREFIX  prov: <http://www.w3.org/ns/prov#>

DELETE {
    GRAPH ?g {
        ?s ?p ?o
    }
} WHERE {
    {
        SELECT DISTINCT ?g WHERE {
        ?g fdri:wasModifiedBy/prov:startedAtTime ?oldStart .
        <{activity}> prov:startedAtTime ?currStart .
        FILTER (?oldStart < ?currStart)
        }
    }
    GRAPH ?g {
        ?s ?p ?o
    }
}