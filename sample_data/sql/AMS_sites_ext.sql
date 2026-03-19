CREATE TABLE sites as from read_csv('./sample_data/src/AMS_sites.csv', AUTO_DETECT=true);
CREATE TABLE lcm_classes as from read_csv('./sample_data/src/LAND_COVER_LCM_CLASSES.csv', AUTO_DETECT=true);
COPY (
    SELECT sites.*,
        CASE WHEN (regexp_matches(site_StationID, '^[^\-]+(-[^\-]+){3}$')) THEN site_StationID ELSE NULL END as station_id,
        CASE WHEN (regexp_matches(site_StationID, '^[^\-]+(-[^\-]+){3}$')) THEN regexp_extract(site_StationID, '[^\-]+(-[^\-]+){2}') ELSE site_StationID END as site_id,
        -- coalesce(regexp_extract(site_StationID, '[^\-]+(-[^\-]+){2}'), site_StationID) as site_id,
        regexp_extract(site_StationID, '[^\-]+') as region_id,
        lcm_classes.LCM_CLASS as site_Land_Management_Class,
        strftime('%Y-%m-%dT%H:%M:00Z', strptime(site_Installation_Date, '%d/%m/%Y %H:%M')) as site_Installation_DateTime,
        strftime('%Y-%m-%dT%H:%M:00Z', strptime(site_Decommissioned_Date, '%d/%m/%Y %H:%M')) as site_Decommissioned_DateTime
    FROM sites left join lcm_classes on sites.site_Land_Management = lcm_classes.DESCRIPTION
) TO './build/AMS_sites_ext.csv' (HEADER, DELIMITER ',') ;