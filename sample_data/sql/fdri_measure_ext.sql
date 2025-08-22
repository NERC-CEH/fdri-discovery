CREATE TABLE IF NOT EXISTS MEASURE AS FROM read_csv('./sample_data/src/fdri_measure.csv', AUTO_DETECT=true) ;
CREATE TABLE IF NOT EXISTS INTERVAL AS FROM read_csv('./sample_data/src/intervalDuration.csv', AUTO_DETECT=true) ;

COPY (
    SELECT
     MEASURE.*,
     INTERVAL.Duration AS measure_Data_Periodicity_Duration
    FROM MEASURE
    LEFT JOIN INTERVAL ON INTERVAL.INTERVAL_ID == MEASURE.measure_Data_Periodicity
)TO './build/fdri_measure_ext.csv';