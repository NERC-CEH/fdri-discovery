CREATE TABLE IF NOT EXISTS PM AS 
    SELECT *,
        split_part(MASK_FILENAME, '_', 1) AS SITE_ID,
        split_part(MASK_FILENAME, '_', 2) AS FEATURE_ID,
        split_part(MASK_FILENAME, '_', 4) AS RESOLUTION,
        strptime(START_DATETIME, '%d-%m-%Y %H:%M') AS START_TS,
        strptime(END_DATETIME, '%d-%m-%Y %H:%M') AS END_TS
FROM read_csv('./sample_data/src/PHENOCAM_MASKS.csv', AUTO_DETECT=true) ;


COPY(
    SELECT SITE_ID, FEATURE_ID, RESOLUTION,
        (SELECT COUNT(*) from PM WHERE SITE_ID=parent.SITE_ID AND FEATURE_ID=parent.FEATURE_ID AND RESOLUTION=parent.RESOLUTION AND START_TS < parent.START_TS) + 1 SEQ,
        MASK_FILENAME,
        strftime(START_TS,'%Y-%m-%dT%H:%M:%SZ') AS START,
        strftime(END_TS,'%Y-%m-%dT%H:%M:%SZ') AS END,
        from PM parent
) TO './build/phenocam_mask_config.csv';