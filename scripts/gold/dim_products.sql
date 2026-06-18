/* 
GOLD LAYER : dim_products

Purpose : In this layer, silver.products and silver.category_translation are merged to 
get comprehensive customer dataset
*/
CREATE SCHEMA IF NOT EXISTS gold;

DROP TABLE IF EXISTS gold.dim_products;
CREATE TABLE gold.dim_products (
    product_id VARCHAR PRIMARY KEY,
    category_pt VARCHAR,
    category_en VARCHAR,
    name_length INT,
    description_length INT,
    photos_qty INT, 
    weight_g NUMERIC,
    length_cm NUMERIC,
    height_cm NUMERIC,
    width_cm NUMERIC,
    dwh_created_at TIMESTAMP
);

INSERT INTO gold.dim_products (product_id, category_pt, category_en, name_length, 
        description_length, photos_qty, weight_g, length_cm, height_cm, width_cm, dwh_created_at)
SELECT 
    p.product_id,
    p.category AS category_pt,
    ct.category_en,
    p.name_length,
    p.description_length,
    p.photos_qty,
    p.weight_g,
    p.length_cm,
    p.height_cm,
    p.width_cm,
    NOW() AS dwh_created_at
FROM silver.products p
LEFT JOIN silver.category_translation ct
ON p.category = ct.category;

