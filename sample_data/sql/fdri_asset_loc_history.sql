CREATE TABLE IF NOT EXISTS SITES AS FROM read_csv('./sample_data/src/SITES_FDRI.csv', AUTO_DETECT=true);
CREATE TABLE IF NOT EXISTS HISTORY AS FROM read_csv('./sample_data/src/fdri_loc_history.csv', AUTO_DETECT=true);
COPY (
    SELECT SITES.StationID, HISTORY.* 
    FROM SITES 
    JOIN HISTORY ON (
        SITES.StationID == HISTORY.locHistory_SiteCode
         OR SITES.StationID == HISTORY.locHistory_SiteCode
    ) 
) TO './build/fdri_asset_loc_history.csv';