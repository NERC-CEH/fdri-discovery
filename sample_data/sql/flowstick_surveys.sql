CREATE TABLE metadata AS 
    SELECT *,
    CASE WHEN Timezone like 'UTC+1%' THEN '+01' ELSE '+00' END as tz_offset
    FROM 'sample_data/src/nivu_flowstick/metadata.parquet';
COPY (
    SELECT *,
    strftime(strptime(CONCAT("stime [-]", "tz_offset"), '%d.%m.%Y %H:%M:%S%z'), '%Y-%m-%dT%H:%M:%SZ') AS "stime",
    strftime(strptime(CONCAT("Date", ' ', "Time", "tz_offset"), '%d.%m.%Y %H:%M:%S%z'), '%Y-%m-%dT%H:%M:%SZ') AS "datetime"
    FROM metadata
) TO 'build/flowstick_surveys.csv'