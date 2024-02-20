# NYC Funds Tracker

### [Click here to NYC Funds Tracker](https://www.fpwa.org/nycfundstracker/)

# Files
## Raw Data: 
 - **Raw Data - Budget** : Raw budget expenditure data from 2011 to 2023 for the nine agencies listed below.
 - **Raw Data - Revenue** :  Raw revenue data from 2011 to 2023 for the nine agencies listed below.
 - **CPI_index.csv** : Annual CPI index for inflation adjustment.
 - **Other_Agencies_Budget.csv** : Total budget expenditure for agencies outside of human services.
 - **Prior_Payable.csv**: The prior payable of each agency. This file will be used in budget expenditure calculation.
 - **Citywide_Data.csv / Citywide_Data.xlsx**: The overall revenue received by NYC agencies. This file will be used to create the dendrogram and the "Revenue Over Time" page.

## Data Validation:
- We match our dashboard data with the records from Annual Comprehensive Financial Report (ACFR)​ \[Tables: G2; G3; G5.​\]
- Data Validation Sources: [ACFR](https://github.com/FPWA-FiscalPolicy/NYC_Funds_Tracker/tree/main/ACFR%20data%20sheets)​


## Data Process:
 - **Step 1 - Download Data** : Use API calls to retrieve data from checkbook NYC. Detailed info can be found in [Read Me Before Downloading.md](https://github.com/FPWA-FiscalPolicy/NYC_Funds_Tracker/blob/main/Code/Step%201%20-Download%20data/Read%20me%20before%20downloading.md)
 - **Step 2 - Merge Data**: Merges budget expenditure and revenue data of human services agencies across all previous years.​​
 - **Step 3 - Data Cleaning**: Filter out the missing values and redundant records; Calculate new columns; Detailed info can be found in [Read Me Before cleaning the data.md](https://github.com/FPWA-FiscalPolicy/NYC_Funds_Tracker/blob/main/Code/Step%203-%20Data%20Cleaning/Read%20me%20before%20cleaning%20the%20data.md)


## Cleaned Data
- After finishing the above three steps, the output data will be saved in "Cleaned data.zip".
- We use the budget expenditure and revenue data in "Cleaned data.zip" to create NYC Funds Tracker.


# Notes:
**FY 2023**: July 1, 2022 to June 30, 2023\
The records in our datasets span from FY2011 to FY2023.

### Human Services Agency
**068**- Administration for Children's Services\
**069**- Department of Social Services;806-Housing Preservation and Development;\
**071**- Department of Homeless Services\
**125**- Department for the Aging\
**260**- Department of Youth and Community Development\
**816**- Department of Health and Mental Hygiene\
**801**- Department of Small Business Services\
**040**- Department of Education\
**806**- Housing Preservation and Development
