{{
    config(materialized = 'table')
}}
WITH src_stores AS (
    SELECT * FROM {{ ref('src_stores') }}
)
SELECT
    store_id,
    store_type,
    store_size
FROM
    src_stores