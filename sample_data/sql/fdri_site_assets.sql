CREATE TABLE IF NOT EXISTS SITES AS FROM read_csv('./sample_data/src/SITES_FDRI.csv', AUTO_DETECT=true);
CREATE TABLE IF NOT EXISTS ASSETS AS FROM read_csv('./sample_data/src/fdri_asset.csv', AUTO_DETECT=true);
COPY (
    SELECT SiteID, ASSETS.* FROM SITES JOIN ASSETS ON SITES.SiteID == ASSETS.asset_Site 
) TO './build/fdri_site_assets.csv';