-- create a database where we will perform queries to test the 
-- scale out thorugh multi cluster virtual warehouse 
CREATE DATABASE TEST_SCALE_OUT;

-- we need to create a large table so that our queries take a bit of time
-- so that we can have a number of concurrent queries running to put load
-- on the system

-- for that we will first load our customer table with 100 rows
-- and then CROSS join several times to generate 20 million rows
CREATE TABLE customer (
  Customer_ID string,
  Customer_Name string ,
  Customer_Email string ,
  Customer_City string ,
  Customer_State string ,
  Customer_DOB DATE
  );

-- this is the same file as we used in the data ingestion lectures
-- create an external stage using the S3 bucket that we created in the last step
create or replace stage bulk_copy_example_stage url='s3://snowflake-essentials/ingesting_data/new_customer';

-- list the files in the bucket
list @bulk_copy_example_stage;

-- bulk copy into the customer table using the stage
-- this loads 100 rows
copy into customer
  from @bulk_copy_example_stage
  pattern='.*.csv'
  file_format = (type = csv field_delimiter = '|' skip_header = 1);

-- create a table called large_table which we will 
-- populate with 20 million rows
CREATE TABLE large_table (
  Customer_ID string,
  Customer_Name string ,
  Customer_Email string ,
  Customer_City string ,
  Customer_State string ,
  Customer_DOB DATE
  );


-- Cross join the customer table several times over
-- producing 100 x 100 x 100 x 20 = 20 Million rows
-- which is then inserted into the large table
-- We have also used the UUID_STRING() to produce
-- totally random data so that it doesn't get optimised
-- in columnar storage resulting in a small table size 
-- as we want the queries on this table to take long
INSERT INTO large_table 
SELECT 
  RANDOM() AS Customer_ID,
  UUID_STRING() AS Customer_Name,
  UUID_STRING() AS Customer_Email,
  UUID_STRING() AS Customer_City,
  UUID_STRING() AS Customer_State,
  A.Customer_DOB
FROM CUSTOMER A CROSS JOIN CUSTOMER B CROSS JOIN CUSTOMER C CROSS JOIN (SELECT TOP 20 * FROM CUSTOMER) D;