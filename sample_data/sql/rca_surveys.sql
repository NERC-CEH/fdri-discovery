CREATE TABLE IF NOT EXISTS metadata AS FROM './sample_data/src/rca_excel/metadata.parquet';
UPDATE metadata SET Date = substr(Date, 0, 11);
COPY (
    SELECT *,
        strftime(try_strptime(CONCAT(Date, ' ', "Start Time"), ['%Y-%m-%d %H:%M:%S', '%Y-%m-%d %H%M']) AT TIME ZONE 'Europe/London', '%Y-%m-%dT%H:%M:%SZ') AS START_TS,
        strftime(try_strptime(CONCAT(Date, ' ', "End Time"), ['%Y-%m-%d %H:%M:%S', '%Y-%m-%d %H%M']) AT TIME ZONE 'Europe/London', '%Y-%m-%dT%H:%M:%SZ') AS END_TS,
    FROM metadata
) TO './build/rca_surveys.csv';