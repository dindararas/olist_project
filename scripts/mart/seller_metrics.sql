/* 
MART LAYER : mart.seller_metrics

*/
CREATE SCHEMA IF NOT EXISTS mart;

DROP TABLE IF EXISTS mart.seller_metrics;
CREATE TABLE mart.seller_metrics(
    seller_id VARCHAR,
    total_orders INT, 
    total_units_sold INT,
    total_sales NUMERIC,
    avg_review_score NUMERIC,
    late_delivery_rate NUMERIC,
    mart_created_at TIMESTAMP
);

INSERT INTO mart.seller_metrics (seller_id, total_orders, total_units_sold, total_sales,
    avg_review_score, late_delivery_rate, mart_created_at)
SELECT 
    seller_id,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(order_item_id) AS total_units_sold,
    SUM(price) AS total_sales,
    ROUND(AVG(avg_review_score), 2) AS avg_review_score,
    ROUND(SUM(is_late_delivery) * 100 / NULLIF(COUNT(is_late_delivery), 0), 2) AS late_delivery_rate,
    NOW() AS mart_created_at
FROM gold.fact_order_items
GROUP BY 1


