create table TS as from read_csv('./sample_data/src/TIMESERIES_IDS.csv', AUTO_DETECT=true);
CREATE TABLE TD aS FROM read_csv('./sample_data/src/TIMESERIES_DEFS.csv', AUTO_DETECT=true) ;

COPY(
SELECT TIMESERIES_ID,
    CONCAT(TD.PARAMETER_ID, '-', TD.UNIT_ID, '-', TD.STATISTIC_ID, '-', TD.RESOLUTION, '-', TD.PERIODICITY) AS MEASURE_ID,
    TD.PROCESS_LEVEL
FROM TS
JOIN TD on TS.TIMESERIES_DEF=TD.TIMESERIES_DEF
) TO './build/time_series_measures.csv' (HEADER, DELIMITER ',') ;
