create table fd as from read_csv('./sample_data/src/NMDB_flag_definitions.csv', AUTO_DETECT=TRUE);
create table ts as from read_csv('./sample_data/src/TIMESERIES_IDS_NMDB.csv', AUTO_DETECT=TRUE);

copy(
select
ts.TIMESERIES_ID,
fd.FLAG_COLUMN,
fd.FLAG_SCHEME
from ts join fd on ts.FLAG_DEF = fd.FLAG_DEF
order by ts.TIMESERIES_ID
) to './build/timeseries_flags_nmdb.csv' with (format csv, header true);
