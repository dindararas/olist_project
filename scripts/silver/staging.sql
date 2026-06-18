/* 
STAGING LAYER : TRANSFORMED TABLES

Purpose : In this layer, the data is transformed : null handling, rename columns, and cast data types

Approaches :
    1. Data is sourced from raw layer
    2. Columns are renamed to the appropriate ones
    3. All the data types are mapped to appropriate data types
    4. Remove invalid dates and invalid values (negative values)
*/
CREATE SCHEMA IF NOT EXISTS silver;

-- silver.customers
DROP TABLE IF EXISTS silver.customers;
CREATE TABLE silver.customers (
    customer_id VARCHAR PRIMARY KEY,
    customer_unique_id VARCHAR,
    zip_code INT,
    city VARCHAR,
    state VARCHAR
);

INSERT INTO silver.customers (customer_id, customer_unique_id, zip_code, city, state)
SELECT 
    TRIM(customer_id) AS customer_id,
    TRIM(customer_unique_id) AS customer_unique_id,
    NULLIF(TRIM(customer_zip_code_prefix), '')::INT AS zip_code,
    COALESCE(TRIM(customer_city), 'N/A' ) AS city,
    COALESCE(TRIM(customer_state), 'N/A') AS state
FROM bronze.customers
WHERE NULLIF(TRIM(customer_id), '') IS NOT NULL;

-- silver.order_items
DROP TABLE IF EXISTS silver.order_items;
CREATE TABLE silver.order_items (
    order_id VARCHAR NOT NULL,
    order_item_id INT NOT NULL,
    product_id VARCHAR NOT NULL,
    seller_id VARCHAR NOT NULL,
    shipping_limit_at TIMESTAMP,
    price NUMERIC,
    freight_value NUMERIC,
    PRIMARY KEY(order_id, order_item_id)
);

INSERT INTO silver.order_items (order_id, order_item_id, product_id, seller_id, 
    shipping_limit_at, price, freight_value)
SELECT 
    TRIM(order_id) AS order_id,
    TRIM(order_item_id)::INT AS order_item_id,
    TRIM(product_id) AS product_id,
    TRIM(seller_id) AS seller_id,
    NULLIF(TRIM(shipping_limit_date), '')::TIMESTAMP AS shipping_limit_at, 
    NULLIF(TRIM(price), '')::NUMERIC AS price,
    NULLIF(TRIM(freight_value), '')::NUMERIC freight_value
FROM bronze.order_items
WHERE NULLIF(TRIM(order_id), '') IS NOT NULL AND 
      NULLIF(TRIM(order_item_id), '') IS NOT NULL AND
      NULLIF(TRIM(product_id), '') IS NOT NULL AND
      NULLIF(TRIM(seller_id), '') IS NOT NULL AND 
      NULLIF(TRIM(price), '')::NUMERIC > 0 AND
       NULLIF(TRIM(freight_value), '')::NUMERIC >= 0 AND
      (NULLIF(TRIM(shipping_limit_date), '')::TIMESTAMP >= '2016-01-01' OR NULLIF(TRIM(shipping_limit_date), '')::TIMESTAMP <= '2018-12-31');

-- silver.geolocation
DROP TABLE IF EXISTS silver.geolocation;
CREATE TABLE silver.geolocation (
    zip_code INT,
    latitude NUMERIC,
    longitude NUMERIC,
    city VARCHAR,
    state VARCHAR
);

INSERT INTO silver.geolocation (zip_code, latitude, longitude, city, state)
SELECT 
    NULLIF(TRIM(geolocation_zip_code_prefix), '')::INT AS zip_code,
    NULLIF(TRIM(geolocation_lat), '')::NUMERIC AS latitude,
    NULLIF(TRIM(geolocation_lng), '')::NUMERIC AS longitude,
    COALESCE(TRIM(geolocation_city), 'N/A') AS city,
    COALESCE(TRIM(geolocation_state), 'N/A') AS state
FROM bronze.geolocation;

-- silver.order_payments
DROP TABLE IF EXISTS silver.order_payments;
CREATE TABLE silver.order_payments (
    order_id VARCHAR,
    payment_sequential INT,
    payment_type VARCHAR,
    payment_installments INT,
    payment_value NUMERIC,
    PRIMARY KEY(order_id, payment_sequential)
);

INSERT INTO silver.order_payments (order_id, payment_sequential, payment_type, 
    payment_installments, payment_value)
SELECT 
    TRIM(order_id) AS order_id,
    TRIM(payment_sequential)::INT AS payment_sequential,
    NULLIF(TRIM(payment_type), 'not_defined') AS payment_type,
    NULLIF(TRIM(payment_installments), '')::NUMERIC AS payment_installments,
    NULLIF(TRIM(payment_value), '')::NUMERIC AS payment_value
FROM bronze.order_payments
WHERE NULLIF(TRIM(order_id), '') IS NOT NULL 
    AND NULLIF(TRIM(payment_sequential), '') IS NOT NULL AND 
    NULLIF(TRIM(payment_value), '')::NUMERIC >= 0;

-- silver.orders
DROP TABLE IF EXISTS silver.orders;
CREATE TABLE silver.orders (
    order_id VARCHAR PRIMARY KEY,
    customer_id VARCHAR NOT NULL,
    order_status VARCHAR,
    purchased_at TIMESTAMP,
    approved_at TIMESTAMP,
    delivered_to_carrier_at TIMESTAMP,
    delivered_to_customer_at TIMESTAMP,
    estimated_delivery_at TIMESTAMP
);

INSERT INTO silver.orders (order_id, customer_id, order_status, purchased_at, approved_at, 
    delivered_to_carrier_at, delivered_to_customer_at, estimated_delivery_at)
SELECT 
    TRIM(order_id) AS order_id,
    TRIM(customer_id) AS customer_id,
    COALESCE(TRIM(order_status), 'unavailable') AS order_status,
    NULLIF(TRIM(order_purchase_timestamp), ''):: TIMESTAMP AS purchased_at,
    NULLIF(TRIM(order_approved_at), '')::TIMESTAMP AS approved_at,
    NULLIF(TRIM(order_delivered_carrier_date), '')::TIMESTAMP AS delivered_to_carrier_at,
    NULLIF(TRIM(order_delivered_customer_date), '')::TIMESTAMP AS delivered_to_customer_at,
    NULLIF(TRIM(order_estimated_delivery_date), ''):: TIMESTAMP AS estimated_delivery_at
FROM bronze.orders
WHERE NULLIF(TRIM(order_id), '') IS NOT NULL AND NULLIF(TRIM(customer_id), '') IS NOT NULL AND
    (NULLIF(TRIM(order_purchase_timestamp), '')::TIMESTAMP < NULLIF(TRIM(order_approved_at), '')::TIMESTAMP
    OR NULLIF(TRIM(order_approved_at), '')::TIMESTAMP < NULLIF(TRIM(order_delivered_carrier_date), '')::TIMESTAMP
    OR NULLIF(TRIM(order_delivered_carrier_date), '')::TIMESTAMP < NULLIF(TRIM(order_delivered_customer_date), '')::TIMESTAMP
    OR NULLIF(TRIM(order_purchase_timestamp), '')::TIMESTAMP < NULLIF(TRIM(order_estimated_delivery_date), '')::TIMESTAMP
    OR NULLIF(TRIM(order_approved_at), '') IS NULL
    OR NULLIF(TRIM(order_delivered_carrier_date), '') IS NULL
    OR NULLIF(TRIM(order_delivered_customer_date), '') IS NULL
  );

-- silver.products
DROP TABLE IF EXISTS silver.products;
CREATE TABLE silver.products (
    product_id VARCHAR PRIMARY KEY,
    category VARCHAR,
    name_length INT,
    description_length INT, 
    photos_qty INT,
    weight_g NUMERIC,
    length_cm NUMERIC,
    height_cm NUMERIC, 
    width_cm NUMERIC
);

INSERT INTO silver.products (product_id, category, name_length, description_length, photos_qty, 
    weight_g, length_cm, height_cm, width_cm)
SELECT 
    TRIM(product_id) AS product_id,
    COALESCE(TRIM(product_category_name), 'uncategorized') AS category,
    NULLIF(TRIM(product_name_lenght), ''):: INT AS name_length,
    NULLIF(TRIM(product_description_lenght), '')::INT AS description_length,
    NULLIF(TRIM(product_photos_qty), '')::INT AS photos_qty,
    NULLIF(TRIM(product_weight_g), '')::NUMERIC AS weight_g,
    NULLIF(TRIM(product_length_cm), '')::NUMERIC AS length_cm,
    NULLIF(TRIM(product_height_cm), '')::NUMERIC AS height_cm,
    NULLIF(TRIM(product_width_cm), '')::NUMERIC AS width_cm
FROM bronze.products
WHERE NULLIF(TRIM(product_id), '') IS NOT NULL;

-- silver.sellers
DROP TABLE IF EXISTS silver.sellers;
CREATE TABLE silver.sellers (
    seller_id VARCHAR PRIMARY KEY,
    seller_zip_code INT,
    seller_city VARCHAR,
    seller_state VARCHAR
);

INSERT INTO silver.sellers (seller_id, seller_zip_code,
    seller_city, seller_state)
SELECT 
    TRIM(seller_id) AS seller_id,
    NULLIF(TRIM(seller_zip_code_prefix), '')::INT AS seller_zip_code,
    COALESCE(TRIM(seller_city), 'N/A') AS seller_city,
    COALESCE(TRIM(seller_state), 'N/A') AS seller_state
FROM bronze.sellers
WHERE NULLIF(TRIM(seller_id), '') IS NOT NULL;

-- silver.order_reviews
DROP TABLE IF EXISTS silver.order_reviews;
CREATE TABLE silver.order_reviews (
    review_id VARCHAR,
    order_id VARCHAR,
    review_score INT,
    review_comment_title VARCHAR,
    review_comment_message VARCHAR,
    review_creation_at TIMESTAMP,
    review_answer_at TIMESTAMP,
    PRIMARY KEY(review_id, order_id)
);

INSERT INTO silver.order_reviews (review_id, order_id, review_score, review_comment_title, 
    review_comment_message, review_creation_at, review_answer_at)
SELECT 
    TRIM(review_id) AS review_id,
    TRIM(order_id) AS order_id,
    NULLIF(TRIM(review_score), '')::INT AS review_score,
    COALESCE(TRIM(review_comment_title), 'N/A') AS review_comment_title, 
    COALESCE(TRIM(review_comment_message), 'N/A') AS review_comment_message,
    NULLIF(TRIM(review_creation_date), '')::TIMESTAMP AS review_creation_at,
    NULLIF(TRIM(review_answer_timestamp), '')::TIMESTAMP AS review_answer_at
FROM bronze.order_reviews
WHERE NULLIF(TRIM(order_id), '') IS NOT NULL AND NULLIF(TRIM(review_id), '') IS NOT NULL AND 
    (NULLIF(TRIM(review_score), '')::INT BETWEEN 1 AND 5);

-- silver.category_translation
DROP TABLE IF EXISTS silver.category_translation;
CREATE TABLE silver.category_translation (
    category VARCHAR PRIMARY KEY,
    category_en VARCHAR
);

INSERT INTO silver.category_translation (category, category_en)
SELECT 
    TRIM(product_category_name) AS category,
    COALESCE(TRIM(product_category_name_english), 'N/A') AS category_en
FROM bronze.category_translation
WHERE NULLIF(TRIM(product_category_name), '') IS NOT NULL;

