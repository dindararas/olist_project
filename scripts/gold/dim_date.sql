/* 
GOLD LAYER : dim_dates
*/

CREATE SCHEMA IF NOT EXISTS gold;
DROP TABLE IF EXISTS gold.dim_date;
CREATE TABLE gold.dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE,
    year INT,
    quarter INT,
    month INT,
    month_name VARCHAR,
    week INT, 
    day_of_month INT, 
    day_of_week INT, -- 1 = Monday, 7 = Sunday
    day_name VARCHAR,
    is_weekend BOOLEAN,
    dwh_created_at TIMESTAMP
);

INSERT INTO gold.dim_date (date_key, full_date, year, quarter, month, month_name,
    week, day_of_month, day_of_week, day_name, is_weekend, dwh_created_at)
SELECT 
    TO_CHAR(d, 'YYYYMMDD')::INT AS date_key,
    d::DATE AS full_date,
    EXTRACT(YEAR FROM d)::INT AS year,
    EXTRACT(QUARTER FROM d)::INT AS quarter,
    EXTRACT(MONTH FROM d)::INT AS month,
    TRIM(TO_CHAR(d, 'Month')) AS month_name,
    EXTRACT(WEEK FROM d)::INT AS week,
    EXTRACT(DAY FROM d)::INT AS day_of_month,
    EXTRACT(ISODOW FROM d)::INT AS day_of_week,
    TRIM(TO_CHAR(d, 'Day')) AS day_name,
    EXTRACT(ISODOW FROM d) IN (6,7) AS is_weekend,
    NOW() AS dwh_created_at
FROM generate_series(
    (SELECT MIN(purchased_at)::DATE FROM silver.orders),
    (SELECT MAX(purchased_at)::DATE FROM silver.orders),
    '1 day'::INTERVAL
) AS d;

