/* =============================================================
   BRONZE LAYER — verify raw ingestion
   Reads the raw Parquet file (converted from CSV by Azure Data
   Factory) directly from the data lake using Synapse serverless
   SQL. No data is moved — OPENROWSET queries the file in place.
   ============================================================= */

SELECT TOP 100 *
FROM OPENROWSET(
    BULK 'https://sthealthcaredevars.dfs.core.windows.net/bronze/healthcare_dataset.parquet',
    FORMAT = 'PARQUET'
) AS rows;
