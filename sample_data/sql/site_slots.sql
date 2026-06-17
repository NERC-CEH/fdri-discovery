create table SI as from read_csv('./sample_data/src/SITE_INSTRUMENTATION.csv', AUTO_DETECT=true);
create table SS as from read_csv('./sample_data/src/SENSOR_SLOT_IDS.csv', AUTO_DETECT=true);
create table SITES as from read_csv('./sample_data/src/SITES_COSMOS.csv', AUTO_DETECT=true);

COPY(
    SELECT DISTINCT SI.SITE_ID, SI.SENSOR_SLOT_ID,SS.SENSOR_SLOT_NAME,SITES.SITE_NAME
    FROM SI
    LEFT JOIN SS
    ON SI.SENSOR_SLOT_ID = SS.SENSOR_SLOT_ID
    LEFT JOIN SITES
    ON SI.SITE_ID = SITES.SITE_ID
) TO './build/site_slots.csv' WITH (HEADER, DELIMITER ',');