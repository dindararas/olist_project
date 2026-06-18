/*

QUALITY CHECKS - STAGING LAYER

Purpose : quality checks for :
1. Null or duplicated primary keys
*/

-- duplicated data
SELECT 
    order_id, 
    order_item_id,
    COUNT(*)
FROM gold.fact_order_items 
GROUP BY 1, 2
HAVING COUNT(*) >1

-- missing values
SELECT 
    COUNT(*) FILTER (WHERE order_id IS NULL) AS null_order_id,
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS null_customer_id,
    COUNT(*) FILTER (WHERE product_id IS NULL) AS null_product_id,
    COUNT(*) FILTER (WHERE seller_id IS NULL) AS null_seller_id,
    COUNT(*) FILTER (WHERE price IS NULL) AS null_price,

-- 

