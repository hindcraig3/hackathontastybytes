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
