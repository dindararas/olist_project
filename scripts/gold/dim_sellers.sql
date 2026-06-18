/* 
GOLD LAYER : dim_sellers

Purpose : In this layer, silver.sellers and silver.geolocation is merged to 
get comprehensive seller dataset
*/
CREATE SCHEMA IF NOT EXISTS gold;

DROP TABLE IF EXISTS gold.dim_sellers;
CREATE TABLE gold.dim_sellers (
    seller_id VARCHAR PRIMARY KEY,
    seller_zip_code INT,
    seller_city VARCHAR,
    seller_state VARCHAR,
    longitude NUMERIC,
    latitude NUMERIC,
    dwh_created_at TIMESTAMP
);

INSERT INTO gold.dim_sellers (seller_id, seller_zip_code, seller_city, 
    seller_state, longitude, latitude, dwh_created_at)
SELECT 
    s.seller_id,
    s.seller_zip_code,
    s.seller_city,
    s.seller_state,
    AVG(g.longitude) AS longitude,
    AVG(g.latitude) AS latitude,
    NOW() AS dwh_created_at
FROM silver.sellers s
LEFT JOIN silver.geolocation g
ON s.seller_zip_code = g.zip_code AND s.seller_city = g.city AND s.seller_state = g.state
GROUP BY 1,2,3,4;


    

