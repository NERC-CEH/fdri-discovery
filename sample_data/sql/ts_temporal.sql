create table ts_times as from read_csv('./sample_data/src/TIMESERIES_TEMPORAL_EXTENTS_COSMOS.csv');
create table ts_ids as from read_csv('./sample_data/src/TIMESERIES_IDS_COSMOS.csv');
COPY(
select TIMESERIES_ID, start_time as START, end_time AS END from ts_ids join ts_times on SITE_ID=site and S3_DATASET=dataset
) TO './build/ts_temporal.csv' (HEADER, DELIMITER ',') ;