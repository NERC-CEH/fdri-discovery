CREATE TABLE IF NOT EXISTS SCI as from read_csv('./sample_data/src/SITE_CALIBRATION_INFO.csv', AUTO_DETECT=true) ;
COPY(
    SELECT *,
    strftime('%Y-%m-%dT%H:%M:%S.000Z', strptime(SAMPLING_START_DATETIME, '%d-%b-%y %H.%M.%S')) AS SAMPLING_START_TIMESTAMP,
    strftime('%Y-%m-%dT%H:%M:%S.000Z', strptime(SAMPLING_END_DATETIME, '%d-%b-%y %H.%M.%S')) AS SAMPLING_END_TIMESTAMP
    FROM SCI
) TO './build/site_calibration_info_clean.csv' (HEADER, DELIMITER ',');