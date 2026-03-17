create table il as from read_csv('./sample_data/src/AMS_issue_log.csv', AUTO_DETECT=true);
create table sites as from read_csv('./build/AMS_sites_ext.csv', AUTO_DETECT=true);
create table notes as from read_csv('./sample_data/src/AMS_issue_log_notes.csv', AUTO_DETECT=true);

COPY (
select il.*,
    sites.site_id,
    sites.station_id,
    sites.site_Network,
    (select max(logNote_Date) from notes where logNote_LogID = il.ID) as log_LastNoteDate,
    (select logNote_Status from notes where logNote_LogID = il.ID and logNote_Date = (select max(logNote_Date) from notes where logNote_LogID = il.ID)) as log_LastNoteStatus
from il
join sites on il.log_Site = sites.station_id or il.log_Site = sites.site_id or il.log_Site = sites.site_Name
) to './build/AMS_issue_log_ext.csv' with (HEADER, DELIMITER ',') ;