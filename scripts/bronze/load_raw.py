# import necessary libraries
import pandas as pd
from sqlalchemy import create_engine, text
import os

# function to connect to db
def connect_to_db() :
    print('Connecting to PostgreSQL...')
    try :
        engine = create_engine('postgresql+psycopg2://olist_user:olist_password@db:5432/olist_db')
        print('Connection successful')
        return engine
    except Exception as e :
        print(f'Database connection failed : {e}')
        raise
    
# function to load csv files to raw database
def load_csv_to_raw(engine, csv_path, table_name) :
    # get schema and table names from table_name
    schema, table = table_name.split('.')

    print(f'Truncating table: {table_name}...')
    with engine.begin() as conn:
        conn.execute(text(f'Truncate Table {table_name}'))
    
    print(f'Inserting data into {table_name}...')

    # read csv files
    df = pd.read_csv(csv_path, dtype=str)

    # insert records to PostgreSQL
    df.to_sql(
        name = table,
        schema= schema,
        con = engine,
        if_exists = 'append',
        index = False
    )

def main() :
    raw_path = '/opt/airflow/data/raw/'

    # dictionary to map csv files to raw table
    tables = {
        'olist_customers_dataset.csv' : 'bronze.customers',
        'olist_geolocation_dataset.csv' : 'bronze.geolocation',
        'olist_order_items_dataset.csv' : 'bronze.order_items',
        'olist_order_payments_dataset.csv' : 'bronze.order_payments',
        'olist_order_reviews_dataset.csv' : 'bronze.order_reviews',
        'olist_orders_dataset.csv' : 'bronze.orders',
        'olist_products_dataset.csv' : 'bronze.products',
        'olist_sellers_dataset.csv' : 'bronze.sellers',
        'product_category_name_translation.csv' : 'bronze.category_translation',
    }

    try :
        engine = connect_to_db()

        print('Loading Raw Layer...')

        for csv_file, table_name in tables.items() :
            csv_path = os.path.join(raw_path, csv_file)
            load_csv_to_raw(engine, csv_path, table_name)

    except Exception as e :
        print(f"An error occurred during execution : {e}")
    
    finally:
        if 'engine' in locals() :
            engine.dispose()
            print('Database connection closed')

main()
