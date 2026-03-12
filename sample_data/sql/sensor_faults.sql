create table if not exists SENSOR_FAULTS as from read_csv('./sample_data/src/SENSOR_FAULTS.csv', AUTO_DETECT=true) ;
create table if not exists SI            as from read_csv('./sample_data/src/SITE_INSTRUMENTATION.csv', AUTO_DETECT=true) ;
create table if not exists TS            as from read_csv('./sample_data/src/TIMESERIES_IDS_COSMOS.csv', AUTO_DETECT=true) ;
create table if not exists faultsSplit   as
    select
        SITE_ID, START_DATETIME, END_DATETIME, str_split(TS_AFFECTED, ';').UNNEST() AS TIMESERIES_ID, REMOVE_DATA, DESCRIPTION_OF_ISSUE
    from
	    SENSOR_FAULTS ;

COPY(
    select
        faultsSplit.*, SI.INSTRUMENT_ID, SI.SERIAL_NUMBER, SI.INSTANCE
    from
        faultsSplit INNER JOIN TS on TS.TIMESERIES_ID == faultsSplit.TIMESERIES_ID
                    LEFT  JOIN SI on
                        faultsSplit.SITE_ID == SI.SITE_ID and
                        SI.SENSOR_SLOT_ID == TS.SENSOR_SLOT_ID and
                        faultsSplit.START_DATETIME >= SI.START_DATETIME and
                        (SI.END_DATETIME is NULL or
                        (faultsSplit.END_DATETIME <= SI.END_DATETIME) or
                        (faultsSplit.END_DATETIME is NULL and SI.END_DATETIME is NULL))
    ) TO './build/sensor_faults.csv'
