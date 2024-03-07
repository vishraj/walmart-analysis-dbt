-- 1: create the s3 snowflake integration object
create or replace storage integration s3_snowflake_int
    TYPE = external_stage
    STORAGE_PROVIDER = S3
    ENABLED = TRUE
    STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::090491204170:role/snowflake-access-role'
    STORAGE_ALLOWED_LOCATIONS = ('s3://walmart-raw-source-vr/');

-- 2: get the user ARN and external ID from the integration object
DESC integration s3_snowflake_int;

-- 3: create the database for file_formats, external stages and pipes
create database if not exists MANAGE_DB;

-- 4: create the file format object
create schema if not exists MANAGE_DB.file_formats;
create or replace file format MANAGE_DB.file_formats.csv_format
    type = csv
    field_delimiter = ','
    skip_header = 1
    null_if = ('NULL', 'null')
    empty_field_as_null = TRUE;

-- 5: create the stage object with the integration and file format object
create schema if not exists MANAGE_DB.EXTERNAL_STAGES;
create or replace stage MANAGE_DB.EXTERNAL_STAGES.walmart_stores_stage
    URL = 's3://walmart-raw-source-vr/stores/'
    STORAGE_INTEGRATION = s3_snowflake_int
    FILE_FORMAT = MANAGE_DB.file_formats.csv_format;

create or replace stage MANAGE_DB.EXTERNAL_STAGES.walmart_departments_stage
    URL = 's3://walmart-raw-source-vr/departments/'
    STORAGE_INTEGRATION = s3_snowflake_int
    FILE_FORMAT = MANAGE_DB.file_formats.csv_format;

create or replace stage MANAGE_DB.EXTERNAL_STAGES.walmart_facts_stage
    URL = 's3://walmart-raw-source-vr/fact_sales/'
    STORAGE_INTEGRATION = s3_snowflake_int
    FILE_FORMAT = MANAGE_DB.file_formats.csv_format;

-- 6: create the schema for the pipe
CREATE OR REPLACE SCHEMA MANAGE_DB.pipes;

-- 7: create the pipes
CREATE OR REPLACE pipe MANAGE_DB.pipes.walmart_stores_pipe
auto_ingest = true
AS
COPY INTO WALMART.RAW.RAW_STORES 
FROM @MANAGE_DB.EXTERNAL_STAGES.walmart_stores_stage;

CREATE OR REPLACE pipe MANAGE_DB.pipes.walmart_departments_pipe
auto_ingest = true
AS
COPY INTO WALMART.RAW.RAW_DEPARTMENTS 
FROM @MANAGE_DB.EXTERNAL_STAGES.walmart_departments_stage;

CREATE OR REPLACE pipe MANAGE_DB.pipes.walmart_facts_pipe
auto_ingest = true
AS
COPY INTO WALMART.RAW.WEEKLY_STORES_SALES
FROM @MANAGE_DB.EXTERNAL_STAGES.walmart_facts_stage;

-- 8: describe pipe
DESC pipe MANAGE_DB.pipes.walmart_stores_pipe;
DESC pipe MANAGE_DB.pipes.walmart_departments_pipe;
DESC pipe MANAGE_DB.pipes.walmart_facts_pipe;


select * from WEEKLY_STORES_SALES;




