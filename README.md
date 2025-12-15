# Tasty Bytes Hackathon

**Welcome to Tasty Bytes!**

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
11. Once added click the **Invite User** button
12. Each user should get an email. Follow the instruction to finsh seting up your user.

### Run the 01_setup.sql script (note only 1 team member needs to do this)

1. Copy the contents of the 01_setup.sql file
2. Create a new worksheet in your shared workspace
3. Paste the contents of the 01_setup.sql file
4. Run all the commands.

### Run the 02_dataload.sql script (note only 1 team member needs to do this)

1. Copy the contents of the 02_dataload.sql file
2. Create a new worksheet in your shared workspace
3. Paste the contents of the 02_dataload.sql file
4. Run all the commands.
5. This will load data into the tables earlier. NOTE: This may take a few minutes to run

## You are now ready to start reviewing and implementing the business and technical requirements. Good luck
