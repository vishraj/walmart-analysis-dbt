WITH raw_departments AS (
    SELECT * FROM {{ source('walmart', 'departments')}}
)
SELECT
    store_id,
    dept_id,
    sales_date,
    weekly_sales,
    is_holiday
FROM
    raw_departments