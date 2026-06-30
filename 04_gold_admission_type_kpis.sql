/* =============================================================
   GOLD LAYER — KPIs by admission type
   Operational view: how patients arrived (Elective / Urgent /
   Emergency) with admissions, average billing, average stay.
   ============================================================= */

USE healthcare_silver;
GO

CREATE EXTERNAL TABLE gold_admission_type_kpis
WITH (
    LOCATION    = 'gold/admission_type_kpis/',
    DATA_SOURCE = lake,
    FILE_FORMAT = parquet_format
)
AS
SELECT
    admission_type,
    COUNT(*)                            AS total_admissions,
    AVG(billing_amount)                 AS avg_billing,
    AVG(CAST(length_of_stay AS FLOAT))  AS avg_length_of_stay
FROM silver_admissions
GROUP BY admission_type;
