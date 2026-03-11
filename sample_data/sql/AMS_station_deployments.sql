create table sites as from read_csv('./sample_data/src/AMS_sites.csv', AUTO_DETECT=true);
create table loc_history as from read_csv('./sample_data/src/AMS_asset_location_history.csv', AUTO_DETECT=true);
COPY(
    select 
        sites.site_StationID,
        loc_history.*
    from sites join loc_history on sites.site_StationID = loc_history.locHistory_SiteCode
) TO './build/AMS_station_deployments.csv' (HEADER, DELIMITER ',') ;