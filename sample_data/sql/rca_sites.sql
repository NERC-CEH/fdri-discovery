COPY (
    SELECT
        str_split("Site Name", ' ')[1] as Site_ID,
        "Site Name",
        "lat",
        "lon"
    FROM './sample_data/src/rca_excel/sites.parquet'
) TO './build/rca_sites.csv';