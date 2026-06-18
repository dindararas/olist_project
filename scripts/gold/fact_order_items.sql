/* 
GOLD LAYER : fact_order_items

Purpose : calculate quantitative columns such as price, freight value, and payment value
*/
CREATE SCHEMA IF NOT EXISTS gold;

DROP TABLE IF EXISTS gold.fact_order_items;
CREATE TABLE gold.fact_order_items (
    fact_key SERIAL PRIMARY KEY, --surrogate key
    order_id VARCHAR NOT NULL,
    order_item_id INT NOT NULL,
    customer_unique_id VARCHAR, 
    customer_id VARCHAR,
    product_id VARCHAR,
    seller_id VARCHAR,
    purchased_date_key INT,
    delivered_date_key INT,
    estimated_date_key INT,
    order_status VARCHAR,
    price NUMERIC,
    freight_value NUMERIC,
    total_payment_value NUMERIC,
    installments INT,
    delivery_delay_days NUMERIC,
    is_late_delivery INT,
    avg_review_score NUMERIC,
    dwh_created_at TIMESTAMP
);

-- create CTE for aggregated payments and review score
WITH agg_payments AS (
    SELECT 
        order_id, 
        MAX(payment_installments) AS installments,
        SUM(payment_value) AS total_payment_value
    FROM silver.order_payments
    GROUP BY 1
),
agg_review AS (
    SELECT 
        order_id, 
        ROUND(AVG(review_score),2) AS avg_review_score
    FROM silver.order_reviews 
    GROUP BY 1
)

-- main query
INSERT INTO gold.fact_order_items (order_id, order_item_id, customer_unique_id, customer_id, 
    product_id, seller_id, purchased_date_key, delivered_date_key, estimated_date_key,
    order_status, price, freight_value, total_payment_value, installments, 
    delivery_delay_days, is_late_delivery, avg_review_score,  dwh_created_at)
SELECT
    -- IDs
    o.order_id,
    oi.order_item_id,
    c.customer_unique_id, 
    o.customer_id,
    oi.product_id,
    oi.seller_id,

    -- Date
    TO_CHAR(o.purchased_at, 'YYYYMMDD')::INT AS purchased_date_key,
    TO_CHAR(o.delivered_to_customer_at, 'YYYYMMDD')::INT AS delivered_date_key,
    TO_CHAR(o.estimated_delivery_at, 'YYYYMMDD')::INT AS estimated_date_key,

    o.order_status,

    oi.price,
    oi.freight_value,
    p.total_payment_value,
    p.installments,
    (o.delivered_to_customer_at:: DATE - o.estimated_delivery_at:: DATE) AS delivery_delay_days,
    CASE 
        WHEN o.delivered_to_customer_at > o.estimated_delivery_at THEN 1 
        ELSE 0 
    END AS is_late_delivery,

    r.avg_review_score,
    NOW() AS dwh_created_at
FROM silver.order_items oi 
JOIN silver.orders o ON o.order_id = oi.order_id
LEFT JOIN silver.customers c ON o.customer_id = c.customer_id
LEFT JOIN agg_payments p ON oi.order_id = p.order_id
LEFT JOIN agg_review r ON oi.order_id = r.order_id;







    


