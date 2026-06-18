/* 
GOLD LAYER : dim_payments

*/
CREATE SCHEMA IF NOT EXISTS gold;

DROP TABLE IF EXISTS gold.dim_payments;
CREATE TABLE gold.dim_payments (
    payment_key SERIAL PRIMARY KEY, --surrogate key
    order_id VARCHAR,
    payment_type VARCHAR,
    dwh_created_at TIMESTAMP
);

INSERT INTO gold.dim_payments (order_id, payment_type, dwh_created_at)
SELECT 
    order_id,
    payment_type,
    NOW() AS dwh_created_at
FROM silver.order_payments



    

