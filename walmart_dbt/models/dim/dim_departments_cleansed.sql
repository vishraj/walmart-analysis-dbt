{{
    config(materialized = 'table')
}}
WITH src_departments AS (
    SELECT * FROM {{ ref('src_departments') }}
)
SELECT
    store_id,
    dept_id,
    sales_date,
    CAST(weekly_sales AS decimal(18,2)) AS weekly_dollar_sales,
    CAST(is_holiday AS BOOLEAN) AS is_holiday
FROM
    src_departments