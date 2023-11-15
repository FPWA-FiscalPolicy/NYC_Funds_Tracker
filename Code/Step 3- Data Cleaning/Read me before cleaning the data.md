# Read Me Before cleaning the data

# Revenue
1. Delete: closing_classification_name= "Collected Unearned Revenue Roll" / "Accounts Left In Old Year";
2. Remove funding class = "INTRA-CITY SALES" / "CAPITAL FUNDS - I.F.A."

# Budget
1. $Actual \ Budget\  Expenditure= Commited +Cash \ Expense$, \
where $Committed= Pre\ Encumbered+Encumbered+Accrued \ Expense+Cash \ Payments+Post \ Adjustments$. 

2. $Agency \ Budget \ Expenditure =  sum(Actual \ Budget\ Expenditure)- Intracity \ Sales - Prior \ Payables$

3. The figrues of "Net Change in Estimates of
Prior Payables" in the Comptroller’s Report—General Fund—Schedule G5 can be found in the Raw data - "Prior_Payable.csv". The figures are hand collected and need to mannually update in the .csv file every year. 

4. Comptroller’s Report—General Fund—Schedule G5 has "_Intra-city sales_", which can be calculated by summing figures in column "_recognized_" across all records with funding class= "INTRA-CITY SALES" in the revenue raw data

# Notes:
1. Comptroller’s Report —General Fund—Schedule G3 has "Net Change in Estimate of Prior Receivables", which can be calculated by summing figures in column "recognized" across all records with [ closing_classification_name= "Accounts Left In Old Year" & funding_class !="INTRA-CITY SALES" &  funding class != "CAPITAL FUNDS - I.F.A."]

