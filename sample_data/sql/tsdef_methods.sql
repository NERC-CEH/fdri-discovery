CREATE TABLE DEP_LINES AS FROM read_json('./build/TIMESERIES_DEF_DEPENDENCIES_LINES.json', auto_detect=true, format=auto);
CREATE TABLE ARGS AS SELECT a.*, b.arg
FROM (SELECT id, derivation, method from DEP_LINES) a
LEFT JOIN (SELECT id, unnest(args) as arg from DEP_LINES) b
ON a.id == b.id ;
COPY (
    SELECT id as TIMESERIES_DEF, derivation as DERIVATION, method as METHOD, arg.key as ARG, arg.value as ARG_VALUE FROM ARGS
) TO './build/tsdef_methods.csv' (HEADER, DELIMITER ',') ;