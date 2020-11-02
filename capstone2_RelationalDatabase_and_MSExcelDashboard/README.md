### SGUS - NTUC Learning Hub - Associate Data Analyst
# Capstone 2: Relational Database and MS Excel Dashboard
## Topics: Singapore Crime Analysis

The goal of this project is to exhibit five stages of the data lifecycle through the use of **SQL** and **MS Excel**, with your own domain of choice. Create insightful **dashboards** as an end result.

Project scope:
1. Data Collection from various sources
2. Creating tables and loading data into SQL databases. 
3. Data Preparation on the raw data, perform data cleaning and transformation operations.
4. Data Analysis using SQL
5. Ceateing Interactive Dashboard and Visualization using excel Dashboards
6. Presenting the data with power point and dashboard

### 1. Data Collection
I collected crime related data from publicly available sources:
- [data.gove.sg](https://data.gov.sg/)
- [department of statistics singapore](https://www.tablebuilder.singstat.gov.sg/publicfacing/viewLatestUpdates.action)   
Data includes overall crime rate, five preventable offences, cases recorded for selected major offences, unlicensed moneylending and harassment, person arrested for selected major offences, victims of selected major offences, and singapore population data.

### 2. SQL databases
Based on the data collected, I design the Entity-Relationship Diagram (ERD) and Relational Schema. Entity (table) creation is based on 3 most common levels of normalization to ensure data integrity.   

I use [ERD Plus](https://erdplus.com/) and [dbdiagram](https://dbdiagram.io/home) to draw Entity-Relationship Diagram and Schema.

### 3. Data Preparation
Once I have the database schema, I prepare the data by cleaning, harmonising, transforming the data using using python and export each of the entity to csv format.  
I created SG Crime database using **SQL Server Management Studio (SSMS)**. 
Data imported into the database through flat file (.csv). 
I created constraint for some of attributes to ensure data integrity.

### 4. Data Analysing using SQL
This step is to discover the underying insights from the dataset by answering the following questions:
- Is there an increase in the overall crime rate over the years?
- What is teh most common type of crime?
- Is crime cases vary greatly by neighborhood?
- What is the offences that seeing increases in recent year?
- Who are more vulnerable to the crime of concern?

### 5. Interactive Dashboard using MS Excel
I created three interactive dashboard in Excel:
- Overall crime
- Five preventable crime, unlicensed money lending & harassment by Neighborhood Police Center (NPC)
- Person Arrested and Victims by Selected Major Offences

## Summary:
- Crime rate through remain low, but seeing increasing trend in two consecutive years 2018, and 2019.
- Most common types of crime is Commercial crimes.
- Total crime cases reported vary by NPC. 
- Increase in Outrage of Modesty cases trend remain a concern.
- Male is more vulnerable to Cheating related offences, but female is more impacted in Outrage of Modesty.


```python

```
