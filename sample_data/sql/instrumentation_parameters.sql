CREATE TABLE IF NOT EXISTS TS AS FROM read_csv('./sample_data/src/TIMESERIES_IDS_COSMOS.csv', AUTO_DETECT=true);
CREATE TABLE IF NOT EXISTS MEASURE AS FROM read_csv('./sample_data/src/MEASURES.csv', AUTO_DETECT=true);
CREATE TABLE IF NOT EXISTS SI AS FROM read_csv('./sample_data/src/SITE_INSTRUMENTATION.csv', AUTO_DETECT=true);

-- Diagnostic: print actual column names
SELECT column_name FROM information_schema.columns WHERE table_name = 'SI';
SELECT column_name FROM information_schema.columns WHERE table_name = 'TS';

COPY (
    SELECT DISTINCT MEASURE.parameter_id, SI.instrument_id
    FROM TS JOIN MEASURE ON TS.measure_id == MEASURE.id 
         JOIN SI ON TS.sensor_slot_id == SI.sensor_slot_id AND TS.site_id == SI.site_id
)TO './build/instrumentation_parameters.csv' (HEADER, DELIMITER ',') ;