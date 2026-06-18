/*

QUALITY CHECKS - SILVER LAYER

Purpose : quality checks for :
1. Null or duplicated primary keys
2. Data standardization and consistency across different tables
3. Invalid date ranges
*/

-- CHECK TABLE: silver.customers
-- Check duplicated customer_id
SELECT 
    customer_id,
    COUNT(*)
FROM silver.customers
GROUP BY 1
HAVING COUNT(*) > 1 ;

-- Check name standardization for city and state across silver.customers and silver.geolocation
SELECT 
    DISTINCT c.city AS city_customers, g.city AS city_geolocation
FROM silver.customers c
LEFT JOIN silver.geolocation g
ON LOWER(c.city) = LOWER(g.city)
WHERE c.city != g.city;

SELECT 
    DISTINCT c.state AS state_customers, g.state AS state_geolocation
FROM silver.customers c
LEFT JOIN silver.geolocation g
ON LOWER(c.state) = LOWER(g.state)
WHERE c.state != g.state;

-- CHECK TABLE: silver.order_items
-- Check duplicated order_id and order_item_id
SELECT 
    order_id,
    order_item_id,
    COUNT(*)
FROM silver.order_items
GROUP BY 1, 2
HAVING COUNT(*) > 1;

-- Check price <= 0 or freight_value<0
SELECT 
    price,
    freight_value
FROM silver.order_items
WHERE price <= 0 OR freight_value < 0;

-- Check shipping_limit_at < 01-01-2016 OR shipping_limit_at > 31-12-2018 
-- In Kaggle, it is said that the dataset is ranging from 2016 to 2018
SELECT *
FROM silver.order_items
WHERE shipping_limit_at < '2016-01-01' OR shipping_limit_at > '2018-12-31';

-- CHECK TABLE: silver.order_payments
-- Check duplicated order_id and payment_sequential
SELECT 
    order_id,
    payment_sequential,
    COUNT(*)
FROM silver.order_payments
GROUP BY 1, 2
HAVING COUNT(*) > 1;

-- Check payment_value <= 0 
SELECT *
FROM silver.order_payments
WHERE payment_value <= 0;

-- CHECK TABLE : silver.orders
-- Check duplicated order_id
SELECT 
    order_id,
    COUNT(*)
FROM silver.orders
GROUP BY 1
HAVING COUNT(*) > 1 ;

-- Check dates in silver.orders
-- Supposed flow : purchased -> approved -> delivered to carrier -> delivered to customer
SELECT *
FROM silver.orders
WHERE purchased_at > approved_at OR approved_at > delivered_to_carrier_at 
    OR delivered_to_carrier_at > delivered_to_customer_at OR
    purchased_at > estimated_delivery_at

-- CHECK TABLE : silver.products
-- Check duplicated product_id
SELECT 
    product_id,
    COUNT(*)
FROM silver.products
GROUP BY 1
HAVING COUNT(*) > 1 ;

-- check negative values for product dimensions
SELECT * 
FROM silver.products 
WHERE weight_g < 0 OR length_cm < 0 OR height_cm < 0 OR width_cm < 0 
     OR photos_qty < 0 OR name_length < 0 OR description_length < 0 ;

-- CHECK TABLE : silver.sellers
-- Check duplicated seller_id
SELECT 
    seller_id,
    COUNT(*)
FROM silver.sellers
GROUP BY 1
HAVING COUNT(*) > 1 ;

-- CHECK TABLE : silver.order_reviews
-- Check duplicated order_id, review_id
SELECT 
    order_id,
    review_id,
    COUNT(*)
FROM silver.order_reviews
GROUP BY 1, 2
HAVING COUNT(*) > 1;

-- Check review_score 
SELECT *
FROM silver.order_reviews
WHERE review_score NOT BETWEEN 1 AND 5;

-- CHECK TABLE : silver.category_translation
-- Check duplicated category
SELECT 
    category,
    COUNT(*)
FROM silver.category_translation
GROUP BY 1
HAVING COUNT(*) > 1 ;
