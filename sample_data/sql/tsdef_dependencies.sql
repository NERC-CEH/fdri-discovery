CREATE TABLE DEP_LINES AS FROM read_json('./build/TIMESERIES_DEF_DEPENDENCIES_LINES.json', auto_detect=true, format=auto);
COPY (
    SELECT id as TIMESERIES_DEF, unnest(depends_on) as DEPENDS_ON from DEP_LINES
) TO './build/tsdef_dependencies.csv' (HEADER, DELIMITER ',') ;