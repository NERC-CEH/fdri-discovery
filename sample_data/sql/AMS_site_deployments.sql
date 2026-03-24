create table sites as from read_csv('./build/AMS_sites_ext.csv', AUTO_DETECT=true);
create table lh as from read_csv('./sample_data/src/AMS_asset_location_history.csv', AUTO_DETECT=true);
create table assets as from read_csv('./sample_data/src/AMS_asset.csv', AUTO_DETECT=true);

create table lhx as select *,
    strftime(locHistory_Date, '%Y-%m-%dT%H:%M:%SZ') as start_date,
    strftime((
        select min(locHistory_Date) from lh as next
        where next.locHistory_AssetID = prev.locHistory_AssetID and next.locHistory_Date > prev.locHistory_Date
    ), '%Y-%m-%dT%H:%M:%SZ') as end_date
    from lh as prev;
COPY(
    select 
        sites.site_id,
        sites.site_Network,
        lhx.*
    from sites 
    join assets on assets.asset_SiteID = sites.ID
    join lhx on lhx.locHistory_AssetID = assets.ID
    where sites.station_id is null
) TO './build/AMS_site_deployments.csv' (HEADER, DELIMITER ',') ;