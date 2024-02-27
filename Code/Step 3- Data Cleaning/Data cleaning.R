# Data Cleaning
library(tidyverse)
library(data.table)
library(RCurl)
library(xlsx)
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
Citywide_federal_grant <- Citywide_data %>%
  filter(Revenue.Category=="Federal Grants and Contracts-Categorical" )%>%
  group_by(year)%>%
  summarize(citywide_federal=sum(as.numeric(Categorical.Citywide.Rev)/2,na.rm = T))
Citywide_state_grant <- Citywide_data %>%
  filter(Revenue.Category=="State Grants and Contracts-Categorical" )%>%
  group_by(year)%>%
  summarize(citywide_state=sum(as.numeric(Categorical.Citywide.Rev)/2,na.rm = T))

Citywide_data <- Citywide_data %>%
  dplyr::select(year,Total.Citywide.Rev,Total.Citywide.Budget,FY_CPI,Adjusted.Total.Citywide.Rev,
                Adjusted.Total.Citywide.Budget)%>%
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
Prior_payable <- read.csv("https://raw.githubusercontent.com/ZoeyyyLyu/NYC_Fund_Tracker/main/RawData/Prior_Payable.csv")
Prior_payable <- Prior_payable %>%
  dplyr::select(-agency_code)
Prior_payable <-left_join(Prior_payable,agency_code_dataframe,by=c("agency"))
Prior_payable <- Prior_payable %>% dplyr::select(-agency)   

# ###############################
# ###### Citywide Revenue  ######
# ###############################
# 
# #11848827000-2348434311-867.67*1000000
# 
# Citywide_rev <-
#   list.files(path = "~/Desktop/NYC_Fund_Tracker/RawData/Raw Data - Citywide Rev/",
#              pattern = "\\.csv$",
#              full.names = T) %>%
#   map_df(~read_csv(., col_types = cols(.default = "c")))
# Citywide_rev$Recognized <- as.numeric(Citywide_rev$Recognized)
# 
# Citywide_rev %>% filter(`Closing Classification Name` != "Collected Unearned Revenue Roll" &
#                           `Closing Classification Name` != "Accounts Left In Old Year")  %>%
#   filter(`Funding Class`=="INTRA-CITY SALES")%>%
#   filter(`Fiscal Year`=="2023")%>%
#   summarise(sum(Recognized,na.rm=T))
# 
# # # calculate Prior Receivables
# # Prior_Receivables <-Citywide_rev %>%
# #   #filter(`Fiscal Year`==2022 )%>%
# #   filter(`Closing Classification Name` == "Accounts Left In Old Year") %>%
# #   filter(`Funding Class` !="INTRA-CITY SALES")%>%
# #   filter(`Funding Class` !="CAPITAL FUNDS - I.F.A.")%>%
# #   group_by(`Revenue Category`,`Fiscal Year`)%>%
# #   summarise(sum_recognize=sum(Recognized,na.rm = T))
# 
# Citywide_rev_summary<- Citywide_rev %>%
#   #filter(`Fiscal Year`==2022)%>%
#   filter(`Closing Classification Name` != "Collected Unearned Revenue Roll" &
#            `Closing Classification Name` != "Accounts Left In Old Year")  %>%
#   filter(`Funding Class` !="INTRA-CITY SALES")%>%
#   filter(`Funding Class` !="CAPITAL FUNDS - I.F.A.")%>%
#   #filter(`Revenue Category`=="Non-Governmental Grants")%>%
#   filter(`Fiscal Year`<=2023 & `Fiscal Year`>=2011) %>%
#   #group_by(`Revenue Category`,`Fiscal Year`)%>%
#   group_by(`Revenue Category`,`Fiscal Year`)%>%
#   summarise(sum_recognize=sum(Recognized,na.rm = T))
# colnames(Citywide_rev_summary) <- c("Revenue_Category","year","Recognized")
# # colnames(Prior_Receivables) <- c("Revenue_Category","year","Prior_Receivable")
# # Citywide_rev_summary <- left_join(Citywide_rev_summary,Prior_Receivables,by=c("Revenue_Category","year"))
# # Citywide_rev_summary$Recognized+Citywide_rev_summary$Prior_Receivable
# 
# #write.csv(Citywide_rev_summary,"~/Desktop/table.csv")
# 

###############################
#### Human Service Revenue  ###
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
Revenue_data <- left_join(Revenue_data,Citywide_federal_grant,by=c("year"))
Revenue_data <- left_join(Revenue_data,Citywide_state_grant,by=c("year"))

Revenue_data %>% filter(year=="2023") %>% group_by(funding_class) %>% summarise(sum(recognized))

CPI <- 299.6855
Revenue_data <-  Revenue_data %>%
  mutate(Adjusted.recognized=recognized*CPI/FY_CPI,
         Adjusted.agency_recog_rev=agency_recog_rev*CPI/FY_CPI,
         Adjusted.citywide_federal=citywide_federal*CPI/FY_CPI,
         Adjusted.citywide_state=citywide_state*CPI/FY_CPI)

Revenue_data$revenue_source <- str_to_title(Revenue_data$revenue_source) 
Revenue_data$funding_class <- str_to_title(Revenue_data$funding_class) 
Revenue_data$revenue_class <- str_to_title(Revenue_data$revenue_class) 


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
# library("xlsx")
agency_Budget_summary$agency_total_budget <- agency_Budget_summary$agency_total_budget-agency_Budget_summary$intracity_sales-
  agency_Budget_summary$Prior.Payable
agency_Budget_summary <- agency_Budget_summary%>% dplyr:: select(-Prior.Payable, -intracity_sales)
Budget_data <- left_join(Budget_data,agency_Budget_summary,by=c("agency_code","year"))

HS_budget_summary <- agency_Budget_summary%>%
  group_by(year)%>%
  summarize(HS_budget=sum(agency_total_budget))

citywide_budget <- Citywide_data%>%
  select (year,Total.Citywide.Budget)

HS_budget_summary <- left_join(HS_budget_summary,citywide_budget,by=c("year"))
# Others <- HS_budget_summary %>%
#  mutate(Other_Agencies=Total.Citywide.Budget-HS_budget) %>%
# select(year,agency_total_budget=Other_Agencies)
# 
# Others <-left_join(Others,Citywide_data,by=c("year"))
# Others <-Others%>%
#   mutate(Adjusted.agency_total_budget=agency_total_budget*299.6855/FY_CPI)

Budget_data <- left_join(Budget_data,Citywide_data,by=c("year"))
Budget_data <-  Budget_data %>%
  mutate(Adjusted.actual_expenditure=actual_expenditure*CPI/FY_CPI,
         Adjusted.agency_total_budget=agency_total_budget*CPI/FY_CPI,
         Path=0)

Other_Agencies <- fread("~/Desktop/NYC_Fund_Tracker/RawData/Other_Agencies_Budget.csv")
Budget_data <- rbind(Budget_data,Other_Agencies)

Budget_data2 <- Budget_data %>%
  mutate(Path=200)

Budget_data <- rbind(Budget_data,Budget_data2)

  
write.csv(Budget_data,"~/Desktop/cleaned_Budget_data.csv")


