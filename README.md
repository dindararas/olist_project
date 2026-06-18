# Data Pipeline for Olist Brazilian E-commerce

## Project Overview
This project builds an automated ELT pipeline to extract dataset from Kaggle API, process, and analyze sales, product performance, and customer in Olist Brazilian e-commerce. The pipeline is fully integrated within Docker and utilize Apache Airflow for workflow orchestration. Metabase is initially used for data visualization, but ended up using Power BI for data visualization.

## Data Pipeline Worflow
<img width="1979" height="1150" alt="data_architecture" src="https://github.com/user-attachments/assets/a123cfb4-4ffe-419d-8454-3c780c5f9cc8" />

1. **Bronze Layer**
  - Use Kaggle API to extract dataset. You can find the dataset [here](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
  - Store raw data in PostgreSQL
  - Managed by `load_raw.py`

2. **Silver Layer**
   - Process raw data into cleaned and standardized dataset
   - Check data quality issues

3. **Gold Layer**
   - Create star-schema with 5 dimension tables and 1 fact table
<img width="871" height="1369" alt="data_modelling" src="https://github.com/user-attachments/assets/ba757d1d-43b0-4765-8024-bff93c9e5064" />

4. **Mart Layer**
   - Create ad-hoc SQL queries for business-analytics use

## Orchestration
The full pipeline is orchestrated with Apache Airflow with the following order :
```mermaid
flowchart LR
    A[download_kaggle_dataset] --> B[create_raw_tables] --> C[bronze_layer] --> D[silver_layer]
    D --> E[gold_dim_customers]
    D --> F[gold_dim_date]
    D --> G[gold_dim_payments]
    D --> H[gold_dim_products]
    D --> I[gold_dim_sellers]
    E --> J[gold_fact_order_items]
    F --> J
    G --> J
    H --> J
    I --> J
    J --> K[mart_customer_segmentation]
    J --> L[mart_monthly_sales]
    J --> M[mart_product_performance]
    J --> N[mart_seller_metrics]
```
## Dashboard
The final dashboard was built in Power BI and covers three areas:
- Sales overview — total revenue, orders, customers, average order value, monthly sales trend, and month-over-month growth
- Product performance — top-selling categories, sales vs order volume by category, and top products by units sold
- Customer analysis — RFM-based customer segmentation (Champions, Loyal, Potential, Churned)
  
## Technologies Used
-  Apache Airflow – Workflow orchestration
-  PostgreSQL – Data storage
-  Docker – Containerization
-  Power BI – Data visualization



