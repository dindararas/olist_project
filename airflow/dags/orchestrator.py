'''
This file is used to orchestrate olist dataset from data collection to business-ready data
Tasks included:
1. Download and unzip dataset from Kaggle
3. Create Raw Tables
4. Bronze Layer
5. Silver Layer 
6. Gold Layer
7. Mart Layer
'''


# import necessary libraries
from airflow import DAG
import sys
from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from datetime import datetime

def load_raw():
    sys.path.append('/opt/airflow/scripts/bronze')
    from load_raw import main
    main()
    
# define DAG
dag = DAG(dag_id = 'olist_pipeline', start_date=datetime(2026, 6, 11), 
          schedule='@once', catchup=False, template_searchpath=['/opt/airflow/scripts'])

with dag:
    # Task 1 : download and unzip dataset from Kaggle
    task_download = BashOperator(
        task_id = 'download_kaggle_datasets',
        bash_command = 'kaggle datasets download -d olistbr/brazilian-ecommerce -p /opt/airflow/data/raw --unzip')

    # Task 2 : create raw tables
    task_create_raw = SQLExecuteQueryOperator(
        task_id = 'create_raw_tables',
        conn_id = 'olist_db',
        sql = 'bronze/create_raw.sql')
    
    # Task 3 : bronze layer
    task_bronze = PythonOperator(
        task_id = 'bronze_layer',
        python_callable = load_raw)
    
    # Task 4 : silver layer
    task_silver = SQLExecuteQueryOperator(
        task_id = 'silver_layer',
        conn_id = 'olist_db',
        sql = 'silver/staging.sql')
    
    # Task 5 : gold layer
    task_dim_customers = SQLExecuteQueryOperator(
        task_id = 'gold_dim_customers',
        conn_id = 'olist_db',
        sql = 'gold/dim_customers.sql')
    task_dim_date = SQLExecuteQueryOperator(
        task_id = 'gold_dim_date',
        conn_id = 'olist_db',
        sql = 'gold/dim_date.sql')
    task_dim_payments = SQLExecuteQueryOperator(
        task_id = 'gold_dim_payments',
        conn_id = 'olist_db',
        sql = 'gold/dim_payments.sql')
    task_dim_products = SQLExecuteQueryOperator(
        task_id = 'gold_dim_products',
        conn_id = 'olist_db',
        sql = 'gold/dim_products.sql')
    task_dim_sellers = SQLExecuteQueryOperator(
        task_id = 'gold_dim_sellers',
        conn_id = 'olist_db',
        sql = 'gold/dim_sellers.sql')
    task_fact = SQLExecuteQueryOperator(
        task_id = 'gold_fact_order_items',
        conn_id = 'olist_db',
        sql = 'gold/fact_order_items.sql')

    # Task 6 : mart layer
    task_mart_customer = SQLExecuteQueryOperator(
        task_id = 'mart_customer_segmentation',
        conn_id = 'olist_db',
        sql = 'mart/customer_segmentation.sql')
    task_mart_sales = SQLExecuteQueryOperator(
        task_id = 'mart_monthly_sales',
        conn_id = 'olist_db',
        sql = 'mart/monthly_sales.sql')
    task_mart_product = SQLExecuteQueryOperator(
        task_id = 'mart_product_performance',
        conn_id = 'olist_db',
        sql = 'mart/product_performance.sql')
    task_mart_seller = SQLExecuteQueryOperator(
        task_id = 'mart_seller_metrics',
        conn_id = 'olist_db',
        sql = 'mart/seller_metrics.sql')
    
    task_download >> task_create_raw >> task_bronze >> task_silver
    task_silver >> [task_dim_customers, task_dim_date, task_dim_payments, task_dim_products, task_dim_sellers] >> task_fact
    task_fact >> [task_mart_customer, task_mart_product, task_mart_sales, task_mart_seller]
    


