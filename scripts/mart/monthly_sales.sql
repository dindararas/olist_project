/* 
MART LAYER : mart.monthly_sales

Purpose : this layer will aggregate data on sales metrics monthly: 
    - total orders
    - total customers
    - total sales
    - total freight value
    - average order value
    - MoM sales growth
*/
CREATE SCHEMA IF NOT EXISTS mart;

-- mart.monthly_sales
DROP TABLE IF EXISTS mart.monthly_sales;
CREATE TABLE mart.monthly_sales (
    year INT,
    month INT,
    month_name VARCHAR,
    total_orders INT,
    total_units_sold INT,
    total_sales NUMERIC,
    total_freight_value NUMERIC,
    avg_order_value NUMERIC,
    mom_sales_percentage NUMERIC,
    mart_created_at TIMESTAMP
);

-- create CTE
WITH monthly AS (
    SELECT 
        d.year,
        d.month,
        d.month_name,
        COUNT(DISTINCT f.order_id) AS total_orders,
        COUNT(f.order_item_id) AS total_units_sold,
        ROUND(SUM(f.price)::NUMERIC, 2) AS total_sales,
        ROUND(SUM(f.freight_value)::NUMERIC, 2) AS total_freight_value,
        ROUND(
            SUM(f.price) / NULLIF(COUNT(DISTINCT f.order_id), 0)::NUMERIC, 2) AS avg_order_value
    FROM gold.fact_order_items f
    LEFT JOIN gold.dim_date d
    ON f.purchased_date_key = d.date_key
    GROUP BY 1, 2, 3
)

-- main query
INSERT INTO mart.monthly_sales (year, month, month_name, total_orders,total_units_sold,
    total_sales, total_freight_value, avg_order_value, mom_sales_percentage, mart_created_at)
SELECT 
    year,
    month,
    month_name,
    total_orders,
    total_units_sold,
    total_sales,
    total_freight_value,
    avg_order_value,
    ROUND(
        (total_sales - LAG(total_sales) OVER(ORDER BY year, month)) / 
        NULLIF(LAG(total_sales) OVER(ORDER BY year, month), 0) * 100::NUMERIC, 2) AS mom_sales_percentage,
    NOW() AS mart_created_at
FROM monthly
ORDER BY year DESC, month ASC;




