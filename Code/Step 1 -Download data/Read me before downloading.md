# Read Me Before Downloading

## Preparation
1. We use API call to download the data from checkbook NYC. [Read the API call syntax here](https://www.checkbooknyc.com/data-feeds/api) ; 
2. API calls will retrieve up to a maximum of 20,000 records per call. In our R script, we have pushed the limit to 60,000 records per call which should be enough for normal retrieval.

## Scripts
1. **_Historical Budget Data.R_** : This script contains a function - Historical_Budget_Data(). It can retrieve all the historical budgetary data from FY 2011 to the current fiscal year.

2. **_Historical Revenue Data.R_** : This script contains a function - Historical_Revenue_Data(). It can retrieve all the historical Revenue data from FY 2011 to the current fiscal year.

3. **_Budget data for a specific year.R_** : This script contains a function - Budget_in_specific_year(). It can retrieve the budgetary data for any specific year.

4. **_Revenue data for a specific year.R_** : This script contains a function - Budget_in_specific_year(). It can retrieve the revenue data for any specific year.


## Notes:
1. Revenue data has column "Fiscal year" and "Budget fiscal year". We use "Fiscal year" as the data selection criterion.

2. Remove Closing Classification Names = "Old Accounts left in the Previous Year" and "Collected Unearned Revenue".

3.  ‘Committed Budget’= sum of ‘Pre-Encumbered’, ‘Encumbered’, ‘Accrued Expense’, ‘Cash Payments’ and ‘Post Adjustments’.

