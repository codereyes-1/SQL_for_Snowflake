// Loading data via Snowpipe. data streaming 
//Stage the data - make streaming data available in snowflake stage
//Test your copy command - create target table & validate your copy into command
//Create pipe - create snow pipe using the tested copy command

// two ways to trigger 
//configure events through cloud platform which trigger when a new file arrives
//when event is triggered it will also trigger the associated pipe which will then load the data
//into the target table 

//second option is to trigger the snow pipe using rest API endpoints 
//writing custom program we can execute whenever we want snowpipe to perform the load
//this can be scheduled or can be polling on a specific directory looking for new files


CREATE OR REPLACE TABLE transactions(
Customer_ID STRING,
Customer_Name STRING,
Customer_Email STRING,
Customer_City STRING,
Customer_Region STRING,
Customer_DOB DATE
);

USE DATABASE ingest_data;

CREATE OR REPLACE STORAGE INTEGRATION S3_SNOWROLE
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::XXXXXXX444206:role/snowrole_s3'
  ENABLED = TRUE 
  STORAGE_ALLOWED_LOCATIONS = ('s3://snowflake-essentials-jd2/', 's3://snowpipe-streamingjd/' )

--create an external stage using an s3 bucket
create or replace stage s3cust_data_stage url='s3://snowflake-essentials-jd2/ingesting_data/new_customer' storage_integration = S3_SNOWROLE;
show stages
list @s3cust_data_stage;
  
desc integration S3_SNOWROLE
--copy this into IAM role trusted relationship: STORAGE_AWS_IAM_USER_ARN, STORAGE_AWS_EXTERNAL_ID
--list the files in the bucket

list @s3cust_data_stage;

COPY INTO transactions FROM @s3cust_data_stage;

COPY INTO transactions FROM @s3cust_data_stage
file_format = (type = csv field_delimiter = ',' skip_header = 1);


DROP PIPE s3transaction_pipe
auto_ingest = true
AS COPY INTO transactions FROM @s3cust_data_stage
file_format = (type = csv field_delimiter = ',' skip_header = 1);

SELECT * FROM transactions;

SHOW PIPES;

-- ////////


create or replace stage s3snowpipe_stage url='s3://snowpipe-streamingjd/transactions/' storage_integration = S3_SNOWROLE;
show stages
list @s3snowpipe_stage;
  
desc integration S3_SNOWROLE
--copy this into IAM role trusted relationship: STORAGE_AWS_IAM_USER_ARN, STORAGE_AWS_EXTERNAL_ID
--list the files in the bucket


COPY INTO transactions FROM @s3snowpipe_stage;

// cp into localSF transactions from externalAWS S3
COPY INTO transactions FROM @s3snowpipe_stage
file_format = (type = csv field_delimiter = ',' skip_header = 1);


CREATE OR REPLACE PIPE s3snow_pipe
auto_ingest = true
AS COPY INTO transactions FROM @s3snowpipe_stage
file_format = (type = csv field_delimiter = ',' skip_header = 1);

SELECT COUNT(*) FROM transactions;

SHOW PIPES;

-- run to check notification channel being used. Will need that info to define notifications in
-- S3 bucket /// arn:aws:sqs:us-northeast-2:942132651395:sf-snowpipe-test-test
 
 
//After file is uploaded, notification is sent to snowpipe which will upload the file. 


