# Data Cleaning
library(tidyverse)
library(data.table)
library(RCurl)
# 068- Administration for Children's Services; 260-Department of Youth and Community Development;
# 125-Department for the Aging; 069-Department of Social Services;806-Housing Preservation and Development;
# 071-Department of Homeless Services; 816-Department of Health and Mental Hygiene;801-Department of Small Business Services
# 040-Department of Education

###############################
###### Data Preparation  ######
###############################
# read revenue data
Revenue_data <- fread('~/Desktop/Merged_data/raw_revenue.csv') # # of obs= 1103781

# construct a agency-code dictionary.
agency_code_dataframe <- data.frame(agency=unique(Revenue_data$agency),
                                    agency_code=c(c('068','260','125','069','806','071','816','801',"040")))
Revenue_data <- left_join(Revenue_data,agency_code_dataframe,by="agency")

# read Budget data
Budget_data <- fread('~/Desktop/Merged_data/raw_budget.csv')
Budget_data <- left_join(Budget_data,agency_code_dataframe,by="agency")

# read Citywide budget and revenue data
#Citywide_data <- read.csv("https://raw.githubusercontent.com/ZoeyyyLyu/NYC_Fund_Tracker/main/Raw%20Data/Citywide_Revenue.xlsx")
Citywide_data <- read.csv("~/Desktop/NYC_Fund_Tracker/RawData/Citywide_Data.csv")
Citywide_data <- Citywide_data %>%
  dplyr::select(-Revenue.Category,-Recognized.Categorical.Citywide.Rev,-Remaining.Categorical.Citywide.Rev,-Path,
                -Adjusted.Recognized.Categorical.Citywide.Rev)%>%
  distinct()


# calculate Intra-city sales
intra_city_sales <- Revenue_data %>%
  filter(closing_classification_name != "Collected Unearned Revenue Roll" &
           closing_classification_name != "Accounts Left In Old Year")  %>%
  filter(funding_class=="INTRA-CITY SALES")%>%
  group_by(agency_code,fiscal_year)%>%
  summarise(intracity_sales=sum(recognized,na.rm=T))
colnames(intra_city_sales)[2] <- c("year")

# calculate Prior_payable
Prior_payable <- read.csv("https://raw.githubusercontent.com/ZoeyyyLyu/NYC_Fund_Tracker/main/Raw%20Data/Prior_Payable.csv")
Prior_payable <- Prior_payable %>%
  dplyr::select(-agency_code)
Prior_payable <-left_join(Prior_payable,agency_code_dataframe,by=c("agency"))
Prior_payable <- Prior_payable %>% dplyr::select(-agency)   


###############################
########### Revenue  ##########
###############################
# clean the raw Revenue_data
  # 1. Delete: closing_classification_name= "Collected Unearned Revenue Roll" / "Accounts Left In Old Year";
  # 2. Remove funding class = "INTRA-CITY SALES" / "CAPITAL FUNDS - I.F.A."
Revenue_data <- Revenue_data %>%
  filter(closing_classification_name != "Collected Unearned Revenue Roll" &
           closing_classification_name != "Accounts Left In Old Year")  %>%
  filter(funding_class !="INTRA-CITY SALES")%>%
  filter(funding_class !="CAPITAL FUNDS - I.F.A.")%>%
  filter(fiscal_year<=2023 & fiscal_year>=2011) %>%
  dplyr::select(-budget_fiscal_year, -V1, -X)

# add a column --  total revenue for every agency  
agency_revenue <- Revenue_data %>%
  group_by(agency_code,fiscal_year)%>%
  summarize(agency_recog_rev=sum(recognized,na.rm=T))
Revenue_data <- left_join(Revenue_data,agency_revenue,by=c("agency_code","fiscal_year"))
Revenue_data <- Revenue_data %>% 
  rename("year" = "fiscal_year")
Revenue_data <- left_join(Revenue_data,Citywide_data,by=c("year"))

write.csv(Revenue_data,"~/Desktop/cleaned_Revenue_data.csv")
###############################
########### Budget  ###########
###############################
# add a column --  actual_expenditure ;   
#‘Committed’ - Sum of ‘Pre-Encumbered’ , ‘Encumbered’ , ‘Accrued Expense’, ‘Cash Payments’ and ‘Post Adjustments’.
# Actual Expenditure= Committed budget + Cash expense 
Budget_data <- Budget_data %>%
  mutate(actual_expenditure=pre_encumbered+encumbered+accrued_expense+post_adjustment+cash_expense)

# add a column --  total budget for every agency  
agency_Budget_summary <- Budget_data %>%
  group_by(agency_code,year)%>%
  summarise(agency_total_budget=sum(actual_expenditure,na.rm=T))
agency_Budget_summary <- left_join(agency_Budget_summary,Prior_payable,by=c("agency_code","year"))
agency_Budget_summary <- left_join(agency_Budget_summary,intra_city_sales,by=c("agency_code","year"))
# total budget expenditure for the agency=  sum(Actual Expenditure)- intra city sales- prior payable
agency_Budget_summary$agency_total_budget <- agency_Budget_summary$agency_total_budget-agency_Budget_summary$intracity_sales-
  agency_Budget_summary$Prior.Payable
agency_Budget_summary <- agency_Budget_summary%>% dplyr:: select(-Prior.Payable, -intracity_sales)

Budget_data <- left_join(Budget_data,agency_Budget_summary,by=c("agency_code","year"))

Budget_data <- left_join(Budget_data,Citywide_data,by=c("year"))

write.csv(Budget_data,"~/Desktop/cleaned_Budget_data.csv")

a <- Budget_data %>%
  filter(year==2023 &agency_code=="068")%>%
  group_by(department)%>%
  summarize(sum_modified=sum(modified,na.rm=T))


#the budget data for ACS is not match! check what happend there!  
  # - missing the column "commited" in budget data
  # - already re-downloaded the data and need to further merge and clean it. After data cleaning, audit again.
# match the rsc to the rev dataset. 
  
