# Read Me Before cleaning the data

# Revenue
1. Delete: closing_classification_name= "Collected Unearned Revenue Roll" / "Accounts Left In Old Year";
2. Remove funding class = "INTRA-CITY SALES" / "CAPITAL FUNDS - I.F.A."

# Budget
1. the Actual budget expenditure=" Commited" +"Cash expense", where ‘Committed’= Sum of ‘Pre-Encumbered’ , ‘Encumbered’ , ‘Accrued Expense’, ‘Cash Payments’ and ‘Post Adjustments’. 

# Notes:
1. Comptroller’s Report —General Fund—Schedule G3 has "Net Change in Estimate of Prior Receivables", which can be calculated by summing figures in column "recognized" across all records with [ closing_classification_name= "Accounts Left In Old Year" & funding_class !="INTRA-CITY SALES" &  funding class != "CAPITAL FUNDS - I.F.A."]

2. Comptroller’s Report—General Fund—Schedule G5 has "intra-city sales", which can be calculated by summing figures in column "recognized" across all records with funding class= "INTRA-CITY SALES" in the revenue raw data
