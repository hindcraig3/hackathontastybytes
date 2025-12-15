/***************************************************************************************************
  _______           _            ____          _             
 |__   __|         | |          |  _ \        | |            
    | |  __ _  ___ | |_  _   _  | |_) | _   _ | |_  ___  ___ 
    | | / _` |/ __|| __|| | | | |  _ < | | | || __|/ _ \/ __|
    | || (_| |\__ \| |_ | |_| | | |_) || |_| || |_|  __/\__ \
    |_| \__,_||___/ \__| \__, | |____/  \__, | \__|\___||___/
                          __/ |          __/ |               
                         |___/          |___/            
***************************************************************************************************/

USE ROLE ACCOUNTADMIN;

-- Set up cross region inference for AI calls.
ALTER ACCOUNT SET CORTEX_ENABLED_CROSS_REGION = 'ANY_REGION';

USE ROLE sysadmin;
-- =============================
-- RESET
-- =============================
--  USE ROLE ACCOUNTADMIN;
--  DROP WAREHOUSE tb_de_wh;
--  DROP DATABASE tastybytes_analytics;
--  DROP ROLE tb_admin;
-- DROP STORAGE INTEGRATION tasybytes_iot_data;
/*--
 • database, schema and warehouse creation
--*/

-- create tastybytes_analytic database
CREATE OR REPLACE DATABASE tastybytes_analytics;

-- create raw schema
CREATE OR REPLACE SCHEMA tastybytes_analytics.raw;
;
-- create transformed schema
CREATE OR REPLACE SCHEMA tastybytes_analytics.transformed;

-- create analytics schema
CREATE OR REPLACE SCHEMA tastybytes_analytics.consumption;

-- create warehouses
CREATE OR REPLACE WAREHOUSE tb_de_wh
    WAREHOUSE_SIZE = 'large' -- Large for initial data load - scaled down to XSmall at end of this scripts
    WAREHOUSE_TYPE = 'standard'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
COMMENT = 'data engineering warehouse for tasty bytes';


-- create roles
USE ROLE securityadmin;

-- functional roles
CREATE ROLE IF NOT EXISTS tb_admin
    COMMENT = 'admin for tasty bytes';
    
-- role hierarchy
GRANT ROLE tb_admin TO ROLE sysadmin;


-- privilege grants
USE ROLE accountadmin;

GRANT IMPORTED PRIVILEGES ON DATABASE snowflake TO ROLE tb_admin;
GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE tb_admin;

USE ROLE securityadmin;

GRANT USAGE ON DATABASE tastybytes_analytics  TO ROLE tb_admin;

GRANT USAGE ON ALL SCHEMAS IN DATABASE tastybytes_analytics TO ROLE tb_admin;
GRANT ALL ON SCHEMA tastybytes_analytics.raw TO ROLE tb_admin;
GRANT ALL ON SCHEMA tastybytes_analytics.transformed TO ROLE tb_admin;
GRANT ALL ON SCHEMA tastybytes_analytics.consumption TO ROLE tb_admin;

-- warehouse grants
GRANT OWNERSHIP ON WAREHOUSE tb_de_wh TO ROLE tb_admin COPY CURRENT GRANTS;
GRANT ALL ON WAREHOUSE tb_de_wh TO ROLE tb_admin;

-- future grants
GRANT ALL ON FUTURE TABLES IN SCHEMA tastybytes_analytics.raw TO ROLE tb_admin;
GRANT ALL ON FUTURE VIEWS IN SCHEMA tastybytes_analytics.transformed TO ROLE tb_admin;
GRANT ALL ON FUTURE VIEWS IN SCHEMA tastybytes_analytics.consumption TO ROLE tb_admin;

-- Apply Masking Policy Grants
USE ROLE accountadmin;
GRANT APPLY MASKING POLICY ON ACCOUNT TO ROLE tb_admin;
  
-- raw table build
USE ROLE tb_admin;
USE WAREHOUSE tb_de_wh;

/*--
 • file format and stage creation
--*/

--File Formt for CSV
CREATE OR REPLACE FILE FORMAT tastybytes_analytics.raw.csv_ff 
type = 'csv';

--Stage for tastybytes_analytics SALES raw data
CREATE OR REPLACE STAGE tastybytes_analytics.raw.s3load_sales
COMMENT = 'Quickstarts S3 Stage Connection'
DIRECTORY = (
    ENABLE = true
    AUTO_REFRESH = true
  )
url = 's3://sfquickstarts/frostbyte_tastybytes/'
file_format = tastybytes_analytics.raw.csv_ff;

--Stage for tastybytes_analytics REVIEW data
CREATE OR REPLACE STAGE tastybytes_analytics.raw.s3load_reviews
COMMENT = 'Quickstarts S3 Stage Connection'
DIRECTORY = (
    ENABLE = true
    AUTO_REFRESH = true
  )
url = 's3://sfquickstarts/tastybytes-voc/'
file_format = tastybytes_analytics.raw.csv_ff ;

/*--
 raw zone table build 
--*/

-- country table build
CREATE OR REPLACE TABLE tastybytes_analytics.raw.country
(
    country_id NUMBER(18,0),
    country VARCHAR(16777216),
    iso_currency VARCHAR(3),
    iso_country VARCHAR(2),
    city_id NUMBER(19,0),
    city VARCHAR(16777216),
    city_population VARCHAR(16777216)
);

-- franchise table build
CREATE OR REPLACE TABLE tastybytes_analytics.raw.franchise 
(
    franchise_id NUMBER(38,0),
    first_name VARCHAR(16777216),
    last_name VARCHAR(16777216),
    city VARCHAR(16777216),
    country VARCHAR(16777216),
    e_mail VARCHAR(16777216),
    phone_number VARCHAR(16777216) 
);

-- location table build
CREATE OR REPLACE TABLE tastybytes_analytics.raw.location
(
    location_id NUMBER(19,0),
    placekey VARCHAR(16777216),
    location VARCHAR(16777216),
    city VARCHAR(16777216),
    region VARCHAR(16777216),
    iso_country_code VARCHAR(16777216),
    country VARCHAR(16777216)
);

-- menu table build
CREATE OR REPLACE TABLE tastybytes_analytics.raw.menu
(
    menu_id NUMBER(19,0),
    menu_type_id NUMBER(38,0),
    menu_type VARCHAR(16777216),
    truck_brand_name VARCHAR(16777216),
    menu_item_id NUMBER(38,0),
    menu_item_name VARCHAR(16777216),
    item_category VARCHAR(16777216),
    item_subcategory VARCHAR(16777216),
    cost_of_goods_usd NUMBER(38,4),
    sale_price_usd NUMBER(38,4),
    menu_item_health_metrics_obj VARIANT
);

-- truck table build 
CREATE OR REPLACE TABLE tastybytes_analytics.raw.truck
(
    truck_id NUMBER(38,0),
    menu_type_id NUMBER(38,0),
    primary_city VARCHAR(16777216),
    region VARCHAR(16777216),
    iso_region VARCHAR(16777216),
    country VARCHAR(16777216),
    iso_country_code VARCHAR(16777216),
    franchise_flag NUMBER(38,0),
    year NUMBER(38,0),
    make VARCHAR(16777216),
    model VARCHAR(16777216),
    ev_flag NUMBER(38,0),
    franchise_id NUMBER(38,0),
    truck_opening_date DATE
);

-- order_header table build
CREATE OR REPLACE TABLE tastybytes_analytics.raw.order_header
(
    order_id NUMBER(38,0),
    truck_id NUMBER(38,0),
    location_id FLOAT,
    customer_id NUMBER(38,0),
    discount_id VARCHAR(16777216),
    shift_id NUMBER(38,0),
    shift_start_time TIME(9),
    shift_end_time TIME(9),
    order_channel VARCHAR(16777216),
    order_ts TIMESTAMP_NTZ(9),
    served_ts VARCHAR(16777216),
    order_currency VARCHAR(3),
    order_amount NUMBER(38,4),
    order_tax_amount VARCHAR(16777216),
    order_discount_amount VARCHAR(16777216),
    order_total NUMBER(38,4)
);

-- order_detail table build
CREATE OR REPLACE TABLE tastybytes_analytics.raw.order_detail 
(
    order_detail_id NUMBER(38,0),
    order_id NUMBER(38,0),
    menu_item_id NUMBER(38,0),
    discount_id VARCHAR(16777216),
    line_number NUMBER(38,0),
    quantity NUMBER(5,0),
    unit_price NUMBER(38,4),
    price NUMBER(38,4),
    order_item_discount_amount VARCHAR(16777216)
);

-- customer loyalty table build
CREATE OR REPLACE TABLE tastybytes_analytics.raw.customer_loyalty
(
    customer_id NUMBER(38,0),
    first_name VARCHAR(16777216),
    last_name VARCHAR(16777216),
    city VARCHAR(16777216),
    country VARCHAR(16777216),
    postal_code VARCHAR(16777216),
    preferred_language VARCHAR(16777216),
    gender VARCHAR(16777216),
    favourite_brand VARCHAR(16777216),
    marital_status VARCHAR(16777216),
    children_count VARCHAR(16777216),
    sign_up_date DATE,
    birthday_date DATE,
    e_mail VARCHAR(16777216),
    phone_number VARCHAR(16777216)
);

-- truck_reviews table build
CREATE OR REPLACE TABLE tastybytes_analytics.raw.truck_reviews
(
    order_id NUMBER(38,0),
    language VARCHAR(16777216),
    source VARCHAR(16777216),
    review VARCHAR(16777216),
    review_id NUMBER(18,0)
);

-- setup completion note
SELECT 'tastybytes_analytics setup is now complete' AS note;


/*
 ============================================================================
 SET UP EXTERNAL INTEGRATION IOT DATA
 ============================================================================
*/


-- USE ROLE ACCOUNTADMIN;
-- DROP STAGE tastybytes_analytics.raw.s3_iot_data;
-- DROP STORAGE INTEGRATION tasybytes_iot_data;
-- DROP FILE FORMAT tastybytes_analytics.raw.json_iot_ff;

USE SCHEMA tastybytes_analytics.raw;
USE ROLE tb_admin;
-- Set up file format for IoT data ingest
CREATE OR REPLACE FILE FORMAT tastybytes_analytics.raw.json_iot_ff
    TYPE = 'JSON'
    COMPRESSION = GZIP
    STRIP_OUTER_ARRAY = TRUE           -- IoT files may contain arrays of records
    IGNORE_UTF8_ERRORS = TRUE          -- Handle any encoding issues gracefully
    COMMENT = 'JSON file format for IoT telemetry data ingestion';
    
USE ROLE ACCOUNTADMIN;
-- Set up storage integration to S3 where the IoT data gets written
CREATE STORAGE INTEGRATION tasybytes_iot_data
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::484577546576:role/chind_snowpipe_data_gen_access'
  STORAGE_ALLOWED_LOCATIONS = ('s3://chind-snowpipe-484577546576-us-west2/');

-- TEAM runs this to get configure details
-- AWS IAM ROLE Trust policy needs to be updated with the extra user ARN's and External id's for each team
DESC INTEGRATION tasybytes_iot_data ->>
    select $1,$3
    from $1 where $1 in ('STORAGE_AWS_IAM_USER_ARN','STORAGE_AWS_EXTERNAL_ID');



/*--
 ============================================================================
 SET UP CHECK
 ============================================================================
--*/
USE ROLE tb_admin;
-- Final summary of all validations
WITH database_check AS (
    SELECT 
        1 AS sort_order,
        'DATABASE' AS object_type,
        'tastybytes_analytics' AS object_name,
        CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL' END AS status
    FROM information_schema.databases
    WHERE database_name = 'TASTYBYTES_ANALYTICS'
),
schema_check AS (
    SELECT 
        2 AS sort_order,
        'SCHEMAS' AS object_type,
        COUNT(*)::VARCHAR || ' of 4 schemas' AS object_name,
        CASE WHEN COUNT(*) >= 4 THEN 'PASS' ELSE 'FAIL' END AS status
    FROM tastybytes_analytics.information_schema.schemata
    WHERE schema_name IN ('RAW', 'TRANSFORMED', 'CONSUMPTION', 'PUBLIC')
),
table_check AS (
    SELECT 
        3 AS sort_order,
        'TABLES (RAW)' AS object_type,
        COUNT(*)::VARCHAR || ' of 9 tables' AS object_name,
        CASE WHEN COUNT(*) = 9 THEN 'PASS' ELSE 'FAIL' END AS status
    FROM tastybytes_analytics.information_schema.tables
    WHERE table_schema = 'RAW'
      AND table_type = 'BASE TABLE'
      AND table_name IN (
          'COUNTRY', 'FRANCHISE', 'LOCATION', 'MENU', 'TRUCK',
          'ORDER_HEADER', 'ORDER_DETAIL', 'CUSTOMER_LOYALTY', 'TRUCK_REVIEWS'
      )
)
SELECT sort_order,object_type, object_name, status
FROM database_check
UNION ALL
SELECT sort_order,object_type, object_name, status
FROM schema_check
UNION ALL
SELECT sort_order,object_type, object_name, status
FROM table_check
ORDER BY sort_order;