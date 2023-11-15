# Data Cleaning
library(tidyverse)
library(data.table)
# 068- Administration for Children's Services; 260-Department of Youth and Community Development;
# 125-Department for the Aging; 069-Department of Social Services;806-Housing Preservation and Development;
# 071-Department of Homeless Services; 816-Department of Health and Mental Hygiene;801-Department of Small Business Services
# 040-Department of Education

#Revenue
Revenue_data <- fread('~/Desktop/Merged_data/raw_revenue.csv') # # of obs= 1103781
#construct a agency-code dictionary.
agency_code_dataframe <- data.frame(agency=unique(Revenue_data$agency),
                                    agency_code=c(c('068','260','125','069','806','071','816','801',"040")))
Revenue_data <- left_join(Revenue_data,agency_code_dataframe,by="agency")

# Intra-city sales
intra_city_sales <- Revenue_data %>%
  filter(closing_classification_name != "Collected Unearned Revenue Roll" &
           closing_classification_name != "Accounts Left In Old Year")  %>%
  filter(funding_class=="INTRA-CITY SALES")%>%
  group_by(agency_code,fiscal_year)%>%
  summarise(intracity_sales=sum(recognized,na.rm=T))
colnames(intra_city_sales)[2] <- c("year")

# clean the raw Revenue_data
  # 1. Delete: closing_classification_name= "Collected Unearned Revenue Roll" / "Accounts Left In Old Year";
  # 2. Remove funding class = "INTRA-CITY SALES" / "CAPITAL FUNDS - I.F.A."
Revenue_data <- Revenue_data %>%
  filter(closing_classification_name != "Collected Unearned Revenue Roll" &
           closing_classification_name != "Accounts Left In Old Year")  %>%
  filter(funding_class !="INTRA-CITY SALES")%>%
  filter(funding_class !="CAPITAL FUNDS - I.F.A.")%>%
  filter(fiscal_year<=2023 & fiscal_year>=2011) %>%
  select(- budget_fiscal_year, -V1, -X)

# add a column --  total revenue for every agency  
agency_revenue <- Revenue_data %>%
  group_by(agency_code,fiscal_year)%>%
  summarize(agency_recog_rev=sum(recognized,na.rm=T))

#Budget
Budget_data <- fread('~/Desktop/Merged_data/raw_budget.csv')
Budget_data <- left_join(Budget_data,agency_code_dataframe,by="agency")

#‘Committed’ - Sum of ‘Pre-Encumbered’ , ‘Encumbered’ , ‘Accrued Expense’, ‘Cash Payments’ and ‘Post Adjustments’.
# Actual Expenditure= Committed budget + Cash expense 
Budget_data <- Budget_data %>%
  mutate(actual_expenditure=pre_encumbered+encumbered+accrued_expense+post_adjustment+cash_expense)

# add a column --  total budget for every agency  
# total budget expenditure for the agency=  sum(Actual Expenditure)- intra city sales- prior payable
Prior_payable <- fread("~/Desktop/")
  
agency_Budget_summary <- Budget_data %>%
  group_by(agency_code,year)%>%
  summarise(agency_total_budget=sum(actual_expenditure,na.rm=T))
agency_Budget_summary <- left_join(agency_Budget_summary,intra_city_sales,by=c("agency_code","year"))
agency_Budget_summary$agency_total_budget <- agency_Budget_summary$agency_total_budget-agency_Budget_summary$intracity_sales

