create table IF NOT EXISTS site_inst as from read_csv('./src/SITE_INSTRUMENTATION.csv', AUTO_DETECT=true) ;
create table IF NOT EXISTS var_inst as from read_csv('./src/VARIABLE_INSTRUMENTATION.csv', AUTO_DETECT=true) ;
create table if not EXISTS var_prop as from read_csv('./src/variableProperties.csv', AUTO_DETECT=true) ;
COPY(
    SELECT site_inst.*, var_inst.*, var_prop.PROPERTY, var_prop.INTERVAL
    FROM site_inst
    INNER JOIN var_inst 
    ON site_inst.INSTRUMENT_ID=var_inst.INSTRUMENT_ID
    LEFT JOIN var_prop
    ON var_inst.VARIABLE_NAME=var_prop.VARIABLE_NAME
    WHERE site_inst.INSTRUMENT_ID != 'DERIVED'
    ORDER BY SITE_ID, site_inst.INSTRUMENT_ID, START_DATETIME
) TO './build/siteInstVar.csv' (HEADER, DELIMITER ',') ;