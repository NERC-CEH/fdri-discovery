create table asset as from read_csv(['./sample_data/src/AMS_mill_assets.csv'], AUTO_DETECT=true, union_by_name=true);
create table sites as from read_csv('./build/AMS_sites_ext.csv', AUTO_DETECT=true);
create table it as from read_csv('./sample_data/src/AMS_instrument_types.csv', AUTO_DETECT=true);

copy(
    select asset.*, sites.site_StationID as StationID, sites.site_id as SiteID, 
    it.Feature1 == 'Sensor' as is_sensor
    from asset
    join sites on asset.asset_SiteID = sites.ID
    join it on asset.asset_Instrument_Type = it.Item
) to './build/AMS_asset_ext.csv' (HEADER, DELIMITER ',') ;