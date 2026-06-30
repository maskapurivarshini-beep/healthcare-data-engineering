/* =============================================================
   SILVER LAYER — clean, type, and enrich
   Standardises patient names, casts dates and billing to proper
   types, engineers length_of_stay and age_group, and filters out
   rows with null keys. Result is written back to the lake as
   Parquet via CETAS (CREATE EXTERNAL TABLE AS SELECT).
   ============================================================= */

-- One-time setup: database + lake source + file format
CREATE DATABASE healthcare_silver;
GO
USE healthcare_silver;
GO

CREATE EXTERNAL DATA SOURCE lake
    WITH (LOCATION = 'https://sthealthcaredevars.dfs.core.windows.net');
GO

CREATE EXTERNAL FILE FORMAT parquet_format
    WITH (FORMAT_TYPE = PARQUET);
GO

-- Build the silver table
CREATE EXTERNAL TABLE silver_admissions
WITH (
    LOCATION    = 'silver/admissions/',
    DATA_SOURCE = lake,
    FILE_FORMAT = parquet_format
)
AS
SELECT
    UPPER(LEFT(name,1)) + LOWER(SUBSTRING(name,2,LEN(name)))      AS patient_name,
    age,
    gender,
    blood_type,
    medical_condition,
    CAST(date_of_admission AS DATE)                              AS admission_date,
    CAST(discharge_date    AS DATE)                              AS discharge_date,
    admission_type,
    insurance_provider,
    CAST(billing_amount AS DECIMAL(12,2))                        AS billing_amount,
    test_results,
    hospital,
    DATEDIFF(DAY, CAST(date_of_admission AS DATE),
                  CAST(discharge_date    AS DATE))               AS length_of_stay,
    CASE
        WHEN age < 19  THEN 'Paediatric'
        WHEN age <= 65 THEN 'Adult'
        ELSE 'Geriatric'
    END                                                         AS age_group
FROM OPENROWSET(
    BULK 'https://sthealthcaredevars.dfs.core.windows.net/bronze/healthcare_dataset.parquet',
    FORMAT = 'PARQUET'
) AS src
WHERE name IS NOT NULL
  AND billing_amount IS NOT NULL;
