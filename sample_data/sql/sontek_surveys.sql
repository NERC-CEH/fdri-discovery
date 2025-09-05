CREATE TABLE metadata AS 
    SELECT *,
      format('{:+03d}', "Local_Time_UTC_Offset_Hours Hours" ::INT) AS "UTC_Offset",
    FROM './sample_data/src/sontek/metadata.parquet';
COPY (
    SELECT 
    CONCAT(Site_Number, ' ', str_split(Local_Start_Time, ' ')[1]) AS "Survey_ID",
    *,
    strftime(CONCAT(Local_Start_Time, UTC_Offset) ::TIMESTAMP, '%Y-%m-%dT%H:%M:%SZ') AS "Start_Time",
    strftime(CONCAT(Local_End_Time, UTC_Offset) ::TIMESTAMP, '%Y-%m-%dT%H:%M:%SZ') AS "End_Time"
    FROM metadata
) TO './build/sontek_surveys.csv';