create table sites as from read_csv('./sample_data/src/AMS_sites.csv', AUTO_DETECT=true);
create table lh as from read_csv('./sample_data/src/AMS_asset_location_history.csv', AUTO_DETECT=true);
create table lhx as select *,
    strftime(locHistory_Date, '%Y-%m-%dT%H:%M:%SZ') as start_date,
    strftime((
        select min(locHistory_Date) from lh as next
        where next.locHistory_AssetID = prev.locHistory_AssetID and next.locHistory_Date > prev.locHistory_Date
    ), '%Y-%m-%dT%H:%M:%SZ') as end_date
    from lh as prev;

COPY(
    select 
        sites.site_StationID,
        sites.site_Network,
        lhx.*
    from sites join lhx on sites.site_StationID = lhx.locHistory_SiteCode
) TO './build/AMS_station_deployments.csv' (HEADER, DELIMITER ',') ;