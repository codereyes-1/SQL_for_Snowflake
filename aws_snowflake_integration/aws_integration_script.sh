CREATE [ OR REPLACE ] STORAGE INTEGRATION [IF NOT EXISTS]
  <name>

CREATE STORAGE INTEGRATION S3_INT
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::xxxxxxx444206:policy/snowflake_access_gen_cust'
  ENABLED = { TRUE }
  STORAGE_ALLOWED_LOCATIONS = ('s3://snowflake-essentials-jd/ingesting_data/new_customer/2022-10-21/*' )
  ``
  
  
  [ STORAGE_BLOCKED_LOCATIONS = ('<cloud>://<bucket>/<path>/' [ , '<cloud>://<bucket>/<path>/' ... ] ) ]
  [ COMMENT = '<string_literal>' ]