/* 
GOLD LAYER : dim_customers

Purpose : In this layer, silver.customers and silver.geolocation is merged to 
get comprehensive customer dataset
*/
CREATE SCHEMA IF NOT EXISTS gold;

DROP TABLE IF EXISTS gold.dim_customers;
CREATE TABLE gold.dim_customers (
    customer_id VARCHAR PRIMARY KEY,
    customer_unique_id VARCHAR,
    zip_code INT,
    city VARCHAR,
    state VARCHAR,
    longitude NUMERIC,
    latitude NUMERIC,
    dwh_created_at TIMESTAMP
);

INSERT INTO gold.dim_customers (customer_id, customer_unique_id, zip_code, city, 
    state, longitude, latitude, dwh_created_at)
SELECT 
    c.customer_id, 
    c.customer_unique_id,
    c.zip_code,
    c.city,
    c.state,
    AVG(g.longitude) AS longitude,
    AVG(g.latitude) AS latitude,
    NOW() AS dwh_created_at
FROM silver.customers c
LEFT JOIN silver.geolocation g
ON c.zip_code = g.zip_code AND c.city = g.city AND c.state = g.state
GROUP BY 1,2,3,4,5;
