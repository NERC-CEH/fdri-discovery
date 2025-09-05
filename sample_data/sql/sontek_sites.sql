COPY(
    SELECT
        "Site Name",
        "Site Number",
        "Latitude",
        "Longitude"
    FROM './sample_data/src/sontek/sites.parquet'
) TO './build/sontek_sites.csv';