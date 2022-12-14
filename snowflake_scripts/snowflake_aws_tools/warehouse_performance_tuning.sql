//Performance tuning
CREATE WAREHOUSE DATASCIENCE_WH WITH WAREHOUSE_SIZE = 'SMALL' WAREHOUSE_TYPE = 'STANDARD' AUTO_SUSPEND = 300 AUTO_RESUME = TRUE

// VW for the DBAs It is sized extra small since DBA queries should normally be of short duration
CREATE OR REPLACE WAREHOUSE DBA_WH WITH WAREHOUSE_SIZE = 'XSMALL' WAREHOUSE_TYPE = 'STANDARD' AUTO_SUSPEND = 300 AUTO_RESUME = TRUE

CREATE ROLE DATA_SCIENTISTS;
GRANT USAGE ON WAREHOUSE DATASCIENCE_WH TO ROLE DATA_SCIENTISTS


CREATE ROLE DBAS;
GRANT USAGE ON WAREHOUSE DBA_WH TO ROLE DBAS;

-- create a login for data scientist & data scientist 2
CREATE OR REPLACE USER DS_1 PASSWORD = secure_password LOGIN_NAME = 'DS-1' DEFAULT_ROLE = DATA_SCIENTISTS EMAIL = "js@mail.com" DEFAULT_WAREHOUSE = DATASCIENCE_WH MUST_CHANGE_PASSWORD = FALSE;
CREATE OR REPLACE USER DS_2 PASSWORD = secure_password LOGIN_NAME = 'DS-2' DEFAULT_ROLE = DATA_SCIENTISTS EMAIL = "js@mail.com" DEFAULT_WAREHOUSE = DATASCIENCE_WH MUST_CHANGE_PASSWORD = FALSE;



GRANT ROLE DATA_SCIENTISTS TO USER DS_1;
GRANT ROLE DATA_SCIENTISTS TO USER DS_2;

 
-- create a login for DBA & data DBA 2
CREATE OR REPLACE USER DBA_1 PASSWORD = secure_password LOGIN_NAME = 'DBA-1' DEFAULT_ROLE = DBAS EMAIL = "js@mail.com" DEFAULT_WAREHOUSE = DBA_WH MUST_CHANGE_PASSWORD = FALSE;
CREATE OR REPLACE USER DBA_2 PASSWORD = secure_password LOGIN_NAME = 'DBA-2' DEFAULT_ROLE = DBAS EMAIL = "js@mail.com" DEFAULT_WAREHOUSE = DBA_WH MUST_CHANGE_PASSWORD = FALSE;


GRANT ROLE DBAS TO USER DBA_1;
GRANT ROLE DBAS TO USER DBA_2;


ALTER USER DS_1 SET PASSWORD = 'secure_password'

describe user DBA_1


USE DATABASE PERFORMANCE_TEST

-- we will use this database to demonstrate queries
GRANT USAGE ON DATABASE PERFORMANCE_TEST TO ROLE PUBLIC;
GRANT USAGE ON SCHEMA PERFORMANCE_TEST.PUBLIC TO ROLE PUBLIC;
GRANT USAGE ON TABLE PERFORMANCE_TEST.PUBLIC.TRANSACTIONS_LARGE TO ROLE PUBLIC;