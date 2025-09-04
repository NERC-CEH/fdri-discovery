COPY (
    SELECT * FROM './sample_data/src/rca_excel/sites.parquet'
) TO './build/rca_sites.csv';