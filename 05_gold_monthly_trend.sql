/* =============================================================
   GOLD LAYER — monthly trend
   Time series of admissions and billing by year and month,
   feeding the dashboard's trend chart.
   ============================================================= */

USE healthcare_silver;
GO

CREATE EXTERNAL TABLE gold_monthly_trend
WITH (
    LOCATION    = 'gold/monthly_trend/',
    DATA_SOURCE = lake,
    FILE_FORMAT = parquet_format
)
AS
SELECT
    YEAR(admission_date)   AS admission_year,
    MONTH(admission_date)  AS admission_month,
    COUNT(*)               AS total_admissions,
    SUM(billing_amount)    AS total_billing
FROM silver_admissions
GROUP BY YEAR(admission_date), MONTH(admission_date);
