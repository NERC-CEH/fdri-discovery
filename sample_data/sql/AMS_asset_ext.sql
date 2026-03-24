create table asset as from read_csv(['./sample_data/src/AMS_asset.csv'], AUTO_DETECT=true, union_by_name=true);
create table sites as from read_csv(['./build/AMS_sites_ext.csv'], AUTO_DETECT=true, union_by_name=true);
copy(
    select asset.*, sites.site_StationID as StationID, sites.site_id as SiteID from asset
    join sites on asset.asset_SiteID = sites.ID
) to './build/AMS_asset_ext.csv' (HEADER, DELIMITER ',') ;