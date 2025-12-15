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
/*--
 raw zone table load 
 NOTE: This may take 1-2 mins. 
 
--*/

-- TRUNCATE TABLE tastybytes_analytics.raw.country;
-- TRUNCATE TABLE tastybytes_analytics.raw.franchise;
-- TRUNCATE TABLE tastybytes_analytics.raw.location ;
-- TRUNCATE TABLE tastybytes_analytics.raw.menu;
-- TRUNCATE TABLE tastybytes_analytics.raw.truck;
-- TRUNCATE TABLE tastybytes_analytics.raw.customer_loyalty;
-- TRUNCATE TABLE tastybytes_analytics.raw.order_detail;
-- TRUNCATE TABLE tastybytes_analytics.raw.truck_reviews;

USE ROLE TB_ADMIN;
ALTER WAREHOUSE tb_de_wh SET WAREHOUSE_SIZE = 'Large';
USE WAREHOUSE tb_de_wh;

-- country table load
COPY INTO tastybytes_analytics.raw.country
FROM @tastybytes_analytics.raw.s3load_sales/raw_pos/country/;

-- franchise table load
COPY INTO tastybytes_analytics.raw.franchise
FROM @tastybytes_analytics.raw.s3load_sales/raw_pos/franchise/;

-- location table load
COPY INTO tastybytes_analytics.raw.location
FROM @tastybytes_analytics.raw.s3load_sales/raw_pos/location/;

-- menu table load
COPY INTO tastybytes_analytics.raw.menu
FROM @tastybytes_analytics.raw.s3load_sales/raw_pos/menu/;

-- truck table load
COPY INTO tastybytes_analytics.raw.truck
FROM @tastybytes_analytics.raw.s3load_sales/raw_pos/truck/;

-- customer_loyalty table load
COPY INTO tastybytes_analytics.raw.customer_loyalty
FROM @tastybytes_analytics.raw.s3load_sales/raw_customer/customer_loyalty/;

-- order_header table load
COPY INTO tastybytes_analytics.raw.order_header
FROM @tastybytes_analytics.raw.s3load_sales/raw_pos/order_header/;

-- order_detail table load
COPY INTO tastybytes_analytics.raw.order_detail
FROM @tastybytes_analytics.raw.s3load_sales/raw_pos/order_detail/;

-- truck_reviews table load
COPY INTO tastybytes_analytics.raw.truck_reviews
FROM @tastybytes_analytics.raw.s3load_reviews/raw_support/truck_reviews/;

-- Reduce the size of the Truck review table
DELETE FROM tastybytes_analytics.raw.truck_reviews
WHERE review_id < (124594-1000);

--- VALIDATE
SELECT TABLE_NAME, ROW_COUNT
FROM tastybytes_analytics.information_schema.tables
WHERE 
    TABLE_SCHEMA='RAW'
ORDER BY 1;


--ALTER WAREHOUSE tb_de_wh SET WAREHOUSE_SIZE = 'XSmall';