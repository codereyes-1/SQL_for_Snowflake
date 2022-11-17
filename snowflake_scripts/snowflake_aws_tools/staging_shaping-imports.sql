CREATE DATABASE ingest_data;

CREATE TABLE customer (
  Customer_ID string,
  Customer_Name string,
  Customer_Email string,
  Customer_City string,
  Customer_State string,
  Customer_DOB DATE
);


create or replace stage jd_copy_stage url='s3://snowflake-essentials-jd/ingesting_data/new_customer/2022-10-21';

create or replace stage bulk_copy_stage url='s3://snowflake-essentials/ingesting_data/new_customer';

USE ROLE ACCOUNTADMIN;
GRANT USAGE ON INTEGRATION S3_CUST TO ROLE SYSADMIN;


list @bulk_copy_stage;

list @jd_copy_stage;

-- load data into table
use database ingest_data;

copy into customer
    from @bulk_copy_stage
    pattern='.*.csv'
    file_format = (type = csv field_delimiter = '|' skip_header = 1);
    
select count(*) from customer;
-- returns count 100

select * from customer limit 10
-- preview 10 records


copy into customer
    from @bulk_copy_stage/2019-09-24/additional_data.txt
    file_format = (type = csv field_delimiter = '|' skip_header = 1);

select count(*) from customer;
-- now will read 200


-- create db if not exist
CREATE DATABASE ingest_data;

USE DATABASE ingest_data;

--create table in whicih we will load the raw json data
CREATE TABLE organisations_json_raw (
    json_data_raw VARIANT);

-- create an external stage using the S3 bucket that contains JSON data
CREATE OR REPLACE STAGE json__stage url ='s3://snowflake-essentials/json_data';

-- list the files in the bucket
LIST @json__stage;

-- copy the _json_file.json into the raw table
COPY INTO organisations_json_raw
    from @json__stage/_json_file.json
    file_format = (type = json);

--copy the _json_file.json into the raw table
SELECT * FROM organisations_json_raw;


--use the snowflake JSON capability to select value of a json attribute format// json_data_raw:data_set//json attribute
SELECT
    json_data_raw:data_set,
    json_data_raw:extract_date
FROM organisations_json_raw;


-- use flatten table function to convert the JSON data into column 
SELECT
    value:name::String,
    value:state::String,
    value:org_code::String,
    json_data_raw:extract_date
FROM
    organisations_json_raw
    , lateral flatten( input => json_data_raw:organisations );
    
    
-- at this stage we can do a 'create table as' to load the columnar data extracted from JSON
CREATE OR REPLACE TABLE organisations_ctas AS
SELECT
    VALUE:name::String AS org_name,
    VALUE:state::String AS state,
    VALUE:org_code::String AS org_code,
    json_data_raw:extract_date AS extract_date
FROM
    organisations_json_raw
    , lateral flatten( input => json_data_raw:organisation );
    
-- and insert the JSON data into the table
INSERT INTO organisations_ctas 
SELECT
    VALUE:name::String AS org_name,
    VALUE:state::String AS state,
    VALUE:org_code::String AS org_code,
	json_data_raw:extract_date AS extract_date
FROM
    organisations_json_raw
    , lateral flatten( input => json_data_raw:organisations );
    
-- validate that the JSON data now indeed appears as proper table
SELECT * FROM organisations_ctas;

-- if you don't want to do a 'create table as' you can pre-create a table
CREATE TABLE organisations (
    org_name STRING,
    STATE    STRING,
    org_code STRING,
    extract_date DATE);

-- and insert the JSON data into the table
INSERT INTO organisations
SELECT
    VALUE:name::STRING AS org_name,
    VALUE:name::STRING AS org_name,
    VALUE:name::STRING AS org_name,
    json_data_raw:extract_date AS extract_date
FROM
    organisations_json_raw
    , lateral flatten( input => json_data_raw:organisations );
    
-- validate that the JSON data appears properly
SELECT * FROM organisations_ctas;
    


CREATE OR REPLACE STAGE test_data_stage url='s3://snowflake-essentials-json-lab/test_data.json'

CREATE OR REPLACE STAGE test_data_json url='s3://snowflake-essentials-json-lab'

LIST @test_data_stage;
LIST @test_data_json;

CREATE TABLE test_data_json_raw (
    json_data_raw VARIANT);


COPY INTO test_data_json_raw
    FROM @test_data_stage/test_data.json
    file_format = (type = json);

SELECT
	json:cdc_date,
    json:customers
FROM test_data_json;



SELECT
    value:Customer_ID::String,
    value:Customer_Name::String,
    value:Customer_Phone::String,
    value:Customer_City::String,
	json:customer
FROM
    test_data_json
    , lateral flatten( input => json:test_data_json );


CREATE OR REPLACE TABLE test_data_ AS
SELECT
    value:Customer_ID::String,
    value:Customer_Name::String,
    value:Customer_Phone::String,
    value:Customer_City::String,
	json:cdc_date
FROM
    test_data_json
    , lateral flatten( input => json_data_raw:test_data_json );


COPY INTO test_data_json_raw
    FROM @test_data_stage/test_data.json
    file_format = (type = json);
    
    
COPY INTO test_datas
    FROM @test_data_json/test_data.json
    file_format = (type = json);
    
COPY INTO test_datas
    FROM @test_data_json/test_data.json    
    pattern='.*.csv'
    file_format = (type = csv field_delimiter = '|' skip_header = 1);
    
    
SELECT * FROM test_data_json;


SELECT * FROM organisations_ctas;

CREATE OR REPLACE TABLE test_datas (
    Customer_City STRING,
    Customer_ID STRING,
    Customer_Name STRING,
    Customer_Phone STRING,
    cdc_date DATE
);

INSERT INTO test_datas
SELECT
    value:Customer_City::String,
    value:Customer_ID::String,
    value:Customer_Name::String,
    value:Customer_Phone::String,
	json:cdc_date AS cdc_date
FROM
    test_data_json
    , lateral flatten( input => json:customers );


SELECT * FROM test_datas;
SELECT * FROM test_datas WHERE Customer_City='Cornwall';
