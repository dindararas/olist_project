/* 
MART LAYER : mart.customer_segmentation

Purpose : this layer will conduct RFM analysis to determine customer group
1. R -> Recency 
2. F -> Frequency 
3. M -> Monetary

All the components will be assigned value 1-5 for each score then combined to derive RFM score
customer group categorization 
RFM Scores :
    511 - 555 -> Champions
    451 - 510 -> Loyal
    351 - 450 -> Potential
    151 - 350 -> Churned
    Else -> Uncategorized
*/
CREATE SCHEMA IF NOT EXISTS mart;

-- mart.customer_segmentation
DROP TABLE IF EXISTS mart.customer_segmentation;
CREATE TABLE mart.customer_segmentation (
    customer_id VARCHAR,
    recency INT,
    frequency INT,
    monetary NUMERIC,
    r_score INT,
    f_score INT,
    m_score INT,
    rfm_score INT,
    customer_group VARCHAR,
    mart_created_at TIMESTAMP
);

-- create CTE
WITH customer_cte AS (
    SELECT 
        f.customer_unique_id AS customer_id,
        MAX(d.full_date) AS last_order_date,
        COUNT(DISTINCT f.order_id) AS frequency,
        SUM(f.price)  AS monetary
    FROM gold.fact_order_items f
    LEFT JOIN gold.dim_date d
    ON f.purchased_date_key = d.date_key
    GROUP BY 1
), reference_date AS (
    SELECT 
        MAX(full_date) AS max_date
    FROM gold.dim_date
    WHERE date_key IN (SELECT purchased_date_key FROM gold.fact_order_items)
), rfm_scores AS (
    SELECT 
        c.customer_id,
        (r.max_date + 1 - c.last_order_date) AS recency,
        c.frequency,
        c.monetary,
        NTILE(5) OVER (ORDER BY r.max_date + 1 - c.last_order_date DESC) AS r_score,
        NTILE(5) OVER(ORDER BY c.frequency ASC) AS f_score,
        NTILE(5) OVER(ORDER BY c.monetary ASC) AS m_score
    FROM customer_cte c
    CROSS JOIN reference_date r
)

-- main query 
-- conduct RFM analysis and categorize customer group
INSERT INTO mart.customer_segmentation (customer_id, recency, frequency, monetary,
    r_score, f_score, m_score, rfm_score, customer_group, mart_created_at)
SELECT 
    customer_id,
    recency,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    -- rfm score
    CONCAT(r_score::TEXT, f_score::TEXT, m_score::TEXT)::INT AS rfm_score,
    CASE 
        WHEN CONCAT(r_score::TEXT, f_score::TEXT, m_score::TEXT)::INT BETWEEN 511 AND 555 THEN 'Champions'
        WHEN CONCAT(r_score::TEXT, f_score::TEXT, m_score::TEXT)::INT BETWEEN 451 AND 510 THEN 'Loyal'
        WHEN CONCAT(r_score::TEXT, f_score::TEXT, m_score::TEXT)::INT BETWEEN 351 AND 450 THEN 'Potential'
        WHEN CONCAT(r_score::TEXT, f_score::TEXT, m_score::TEXT)::INT BETWEEN 151 AND 350 THEN 'Churned'
        ELSE 'Uncategorized' 
    END AS customer_group,
    NOW() AS mart_created_at
FROM rfm_scores;
    




