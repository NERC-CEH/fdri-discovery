CREATE TABLE IF NOT EXISTS SITES AS FROM read_csv('./sample_data/src/SITES_FDRI.csv', AUTO_DETECT=true);
CREATE TABLE IF NOT EXISTS HISTORY AS FROM read_csv('./sample_data/src/fdri_loc_history.csv', AUTO_DETECT=true);
COPY (
    SELECT SITES.SiteID, HISTORY.*
    FROM SITES 
    JOIN HISTORY ON (
        SITES.SiteID == HISTORY.locHistory_SiteCode
    ) 
) TO './build/fdri_asset_loc_history.csv';