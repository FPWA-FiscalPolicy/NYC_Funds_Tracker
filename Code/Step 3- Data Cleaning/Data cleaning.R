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
Revenue_data <- Revenue_data %>%
  filter(closing_classification_name != "Collected Unearned Revenue Roll" &
           closing_classification_name != "Accounts Left In Old Year")  %>%
  filter(funding_class !="INTRA-CITY SALES")%>%
  filter(funding_class !="CAPITAL FUNDS - I.F.A.")%>%
  filter(fiscal_year<=2023 & fiscal_year>=2011) 
Revenue_data <- left_join(Revenue_data,agency_code_dataframe,by="agency")


#Budget
Budget_data <- fread('~/Desktop/Merged_data/raw_budget.csv')
Budget_data <- left_join(Budget_data,agency_code_dataframe,by="agency")

#‘Committed’ - Sum of ‘Pre-Encumbered’ , ‘Encumbered’ , ‘Accrued Expense’, ‘Cash Payments’ and ‘Post Adjustments’.
# Actual Expenditure=Committed budget + Cash expense
Budget_data <- Budget_data %>%
  mutate(actual_expenditure=pre_encumbered+encumbered+accrued_expense+post_adjustment+cash_expense)

#Budget
Revenue_data <- fread('~/Desktop/Merged_data/raw_revenue.csv')
Revenue_data %>%
  filter(closing_classification_name != "Collected Unearned Revenue Roll" &
           closing_classification_name != "Accounts Left In Old Year")  %>%
  filter(funding_class=="INTRA-CITY SALES")%>%
  group_by(fiscal_year,agency)%>%
  summarise(sum_recog=sum(recognized,na.rm=T))
