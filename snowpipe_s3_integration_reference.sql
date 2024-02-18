-- 1: create the s3 snowflake integration object
create or replace storage integration s3_snowflake_int
    TYPE = external_stage
    STORAGE_PROVIDER = S3
    ENABLED = TRUE
    STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::090491204170:role/snowflake-access-role'
    STORAGE_ALLOWED_LOCATIONS = ('s3://vr-snowpipe-test/', 's3://walmart-raw-source-vr/')

-- 2: get the user ARN and external ID from the integration object
DESC integration s3_snowflake_int;

-- 3: create the destination table
CREATE OR REPLACE TABLE STORES (
    STORE_ID integer,
    STORE_TYPE string,
    STORE_SIZE integer
)

-- 4: create the file format object
create or replace file format MANAGE_DB.file_formats.csv_format
    type = csv
    field_delimiter = ','
    skip_header = 1
    null_if = ('NULL', 'null')
    empty_field_as_null = TRUE;
    
-- 5: create the stage object with the integration and file format object
create or replace stage MANAGE_DB.EXTERNAL_STAGES.snowpipe_test_csv
    URL = 's3://vr-snowpipe-test/sales/'
    STORAGE_INTEGRATION = s3_snowflake_int
    FILE_FORMAT = MANAGE_DB.file_formats.csv_format

-- 6: test the integration with a manual copy command
--COPY INTO WALMART.SNOWPIPE_TEST.STORES
--    FROM @MANAGE_DB.EXTERNAL_STAGES.snowpipe_test_csv

-- 7: create the schema for the pipe
CREATE OR REPLACE SCHEMA MANAGE_DB.pipes

-- 8: create the pipe
CREATE OR REPLACE pipe MANAGE_DB.pipes.snowpipe_test_pipe
auto_ingest = true
AS
COPY INTO WALMART.SNOWPIPE_TEST.STORES 
FROM @MANAGE_DB.EXTERNAL_STAGES.snowpipe_test_csv

-- 9: describe pipe
DESC pipe MANAGE_DB.pipes.snowpipe_test_pipe

-- 10: validate if a pipe is working
SELECT SYSTEM$PIPE_STATUS('MANAGE_DB.pipes.snowpipe_test_pipe')

-- 11: snowpipe error messages
SELECT * FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
    table_name => 'WALMART.SNOWPIPE_TEST.STORES',
    START_TIME => DATEADD(HOUR, -2, CURRENT_TIMESTAMP())
))


