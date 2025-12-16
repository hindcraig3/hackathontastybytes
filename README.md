# Tasty Bytes Hackathon

**Welcome to Tasty Bytes!** :wave:

Your mission is to enable Tasty Bytes to better understand it's business with data. 

To get you started we have provided you the following:

* **Business and Technical Requirements** : This contains the business and technical requirements you need to deliver.
* **01_setup.sql** : This contains code to set up your team environment
* **02_dataload.sql**: This contains code to load data into the tables in the raw layer.

## Team Set up instructions

Each team will have Snowflake trial account and the whole team will work in theat account.

### Set up trial account (note only 1 team member needs to do this)
1. Navigate to [https://trial.snowflake.com/](https://trial.snowflake.com/) and set up a new trial account as per the instructions
  
1. Once you have set up a trial account and verified your email log into your trial account
2. Navigate to **Catalog -> Database Explorer** and click the **+ Database** button to create a new database
3. Name it: **Sharedworkspaces** and click **Create**
4. Navigate to **Projects -> Workspaces** then in the middle pane lcick **My Worksapce**
5. At the bottom of the mneu click **Shared Workspace**
6. Give it a name, then select the **Sharedworkspaces** database and the **public** schema. Share it with the **ACCOUNTADMIN** role
7. Click **Create** to create your shared workspace.
8. Navigate to **Governance & Security --> Users & roles**
9. Click the **INVITE** button.
10. Add each team members email address and the ACCOUNTADMIN role.
11. Add each Snowflake supporters email address and the ACCOUNTADMIN role.
12. Once added click the **Invite User** button
13. Each user should get an invitation email. Follow the instruction to finish seting up your user.

### Run the 01_setup.sql script (note only 1 team member needs to do this)

1. Copy the contents of the **01_setup.sql** file
2. Create a new worksheet in your shared workspace
3. Paste the contents of the **01_setup.sql** file
4. Run all the commands.

### Run the 02_dataload.sql script (note only 1 team member needs to do this)

1. Copy the contents of the **02_dataload.sql** file
2. Create a new worksheet in your shared workspace
3. Paste the contents of the **02_dataload.sql** file
4. Run all the commands.
5. This will load data into the tables earlier. NOTE: This may take a few minutes to run

### Create a validation Worksheet in your Workspace

When you have completed a requirement the Snowflake team will validate you have "delivered" the requirements. To do this you will add any queries you create to met the success criterai intothe **validation worksheet** then let the Snowflake team know it is ready to be tested.

1. In your share workspace create a new worksheet called **Validation**
2. When you have completed a requirement add you queries into the **validation** worksheet. Make sure you add a comment that explains what requirement and success criteria the query is for
3. :warning: You must remember to click the **Publish Changes** btton on the worksheet to allow others, including Snowflake , to see the changes :warning:


:white_check_mark: **You are now ready to start reviewing and implementing the business and technical requirements. Good luck**

# HINTS and TIPS

**REQ 2 : Gain insights in Truck sales**

* Gross profit can be calculated at the ORDER_DETAIL level. You'll need to get the ITEM COST from the menu table.
* You can then create a query that brings together TRUCK, FRANCHISE, ORDER_HEADER,ORDER_LINE and MENU.
* Remember the MENU table contains menu items AND menu_type so you may need to figure out how to get a distinct list of menu_type_id's and truck Brands. A Common Table expression (CTE) may be useful. e.g
  ```
  WITH listoftruckbrands AS
  (
    Select distinct menu_type_id, truck_brand_name from tastybytes_analytics.raw.menu;
  )
  Select
    *
  FROM
    listoftruckbrands b
    JOIN TRUCK t on b.menu_type_id = t..menu_type_id ;
  ```

**REQ 3: Gain Insights into Areas for Improvement**

This query uses AI_COMPLETE() to extract the issues from a truck review. You may then need to have some additonal SQL to flatten out the JSON response. 
Using A Common Table Expression may be useful.

```
SELECT 
        REVIEW_ID,
        AI_COMPLETE(
            model => 'claude-4-sonnet',
            prompt => 'Analyze this food truck customer review and identify specific areas for improvement. Classify areas for improvement as operational issue, food quality issue, service issue. : ' || REVIEW,
            response_format => {
                        'type' : 'json',
                        'schema' : {
                                'type' : 'object', 'properties' : {
                                    'areas_for_improvement': {'type' : 'object', 'properties': {
                                        'operational' : {'type' : 'boolean'},
                                        'food_quality' : {'type' : 'boolean'},
                                        'service' : {'type' : 'boolean'}
                                        }
                                    }
                                }
                        }
                    }
        ) AS improvement_areas
    FROM TASTYBYTES_ANALYTICS.RAW.TRUCK_REVIEWS r
        JOIN tastybytes_analytics.raw.order_header h on r.order_id = h.order_id
    WHERE REVIEW IS NOT NULL 
      AND LENGTH(TRIM(REVIEW)) > 0
```
**REQ 5 : Ingest IoT data**

Here is some sample code to create your Snowpipe.  This assumes you have created a table called truck_iot with the specified format ( Check business requirements)

```
CREATE or REPLACE PIPE tastybytes_analytics.raw.tasty_iot_pipe
  AUTO_INGEST = TRUE
  AWS_SNS_TOPIC='<SNS TOPIC ARN GOES HERE>'
  AS
    COPY INTO tastybytes_analytics.raw.truck_iot (raw_payload,source_filename,load_timestamp)
      FROM (
        select $1::VARIANT,
        METADATA$FILENAME,
        CURRENT_TIMESTAMP()
        from  @tastybytes_analytics.raw.s3_iot_data
      )
      FILE_FORMAT = tastybytes_analytics.raw.json_iot_ff;
```
