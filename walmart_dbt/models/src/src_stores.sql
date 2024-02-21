WITH raw_stores AS (
    SELECT * FROM {{ source('walmart', 'stores') }}
)
SELECT
    store_id,
    store_type,
    store_size
FROM
    raw_stores