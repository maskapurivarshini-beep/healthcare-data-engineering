/* =============================================================
   GOLD LAYER — KPIs by medical condition
   Cost and outcome metrics aggregated per condition:
   admissions, average / total billing, average length of stay,
   and the share of admissions with abnormal test results.
   ============================================================= */

USE healthcare_silver;
GO

CREATE EXTERNAL TABLE gold_condition_kpis
WITH (
    LOCATION    = 'gold/condition_kpis/',
    DATA_SOURCE = lake,
    FILE_FORMAT = parquet_format
)
AS
SELECT
    medical_condition,
    COUNT(*)                                                          AS total_admissions,
    AVG(billing_amount)                                               AS avg_billing,
    SUM(billing_amount)                                               AS total_billing,
    AVG(CAST(length_of_stay AS FLOAT))                               AS avg_length_of_stay,
    SUM(CASE WHEN test_results = 'Abnormal' THEN 1 ELSE 0 END) * 1.0
        / COUNT(*)                                                   AS abnormal_rate
FROM silver_admissions
GROUP BY medical_condition;
