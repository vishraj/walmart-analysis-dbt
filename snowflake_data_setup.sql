-- Use an admin role
USE ROLE ACCOUNTADMIN;

-- Create the `transform` role
CREATE ROLE IF NOT EXISTS transform;
GRANT ROLE TRANSFORM TO ROLE ACCOUNTADMIN;

-- Create the default warehouse if necessary
CREATE WAREHOUSE IF NOT EXISTS COMPUTE_WH;
GRANT OPERATE ON WAREHOUSE COMPUTE_WH TO ROLE TRANSFORM;

-- Create the `dbt` user and assign to role
CREATE USER IF NOT EXISTS dbt
  PASSWORD='dbtPassword123'
  LOGIN_NAME='dbt'
  MUST_CHANGE_PASSWORD=FALSE
  DEFAULT_WAREHOUSE='COMPUTE_WH'
  DEFAULT_ROLE='transform'
  DEFAULT_NAMESPACE='WALMART.RAW'
  COMMENT='DBT user used for data transformation';
GRANT ROLE transform to USER dbt;

-- Create our database and schemas
CREATE DATABASE IF NOT EXISTS WALMART;
CREATE SCHEMA IF NOT EXISTS WALMART.RAW;

-- Set up permissions to role `transform`
GRANT ALL ON WAREHOUSE COMPUTE_WH TO ROLE transform; 
GRANT ALL ON DATABASE WALMART to ROLE transform;
GRANT ALL ON ALL SCHEMAS IN DATABASE WALMART to ROLE transform;
GRANT ALL ON FUTURE SCHEMAS IN DATABASE WALMART to ROLE transform;
GRANT ALL ON ALL TABLES IN SCHEMA WALMART.RAW to ROLE transform;
GRANT ALL ON FUTURE TABLES IN SCHEMA WALMART.RAW to ROLE transform;

-- Set up the defaults
USE WAREHOUSE COMPUTE_WH;
USE DATABASE WALMART;
USE SCHEMA RAW;

-- raw tables
create or replace table raw_departments (
    store_id integer,
    dept_id integer,
    sales_date datetime,
    weekly_sales string,
    is_holiday string
);

create or replace table raw_stores (
    store_id integer,
    store_type string,
    store_size integer
);

create or replace table weekly_stores_sales (
    store_id integer,
    sale_date datetime,
    temperature string,
    fuel_price string,
    markdown1 string,
    markdown2 string,
    markdown3 string,
    markdown4 string,
    markdown5 string,
    cpi string,
    unemployment string,
    is_holiday string
);