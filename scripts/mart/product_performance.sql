/* 
MART LAYER : mart.product_performance

*/
CREATE SCHEMA IF NOT EXISTS mart;

DROP TABLE IF EXISTS mart.product_performance;
CREATE TABLE mart.product_performance(
    product_id VARCHAR,
    total_orders INT, 
    total_units_sold INT,
    total_sales NUMERIC,
    avg_review_score NUMERIC,
    mart_created_at TIMESTAMP
);

INSERT INTO mart.product_performance (product_id, total_orders, total_units_sold, total_sales,
    avg_review_score,  mart_created_at)
SELECT 
    product_id,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(order_item_id) AS total_units_sold,
    SUM(price) AS total_sales,
    ROUND(AVG(avg_review_score), 2) AS avg_review_score,
    NOW() AS mart_created_at
FROM gold.fact_order_items
GROUP BY 1
