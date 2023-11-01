# Read Me before Downloading

## Preparation
1. We use API call to download the data from checkbook NYC. [Read the API call syntax here](https://www.checkbooknyc.com/data-feeds/api) ; 
2. API calls will retrieve up to a maximum of 20,000 records per call. In our R script, we have pushed the limit to 60,000 records per call which should be enough for normal retrieval.

## Scripts
1. **_Historical Budget Data.R_** : This script contains a function - Historical_Budget_Data(). It can retrieve all the historical budgetary data from FY 2011 to the current fiscal year.

2. **_Historical Revenue Data.R_** : This script contains a function - Historical_Revenue_Data(). It can retrieve all the historical Revenue data from FY 2011 to the current fiscal year.

