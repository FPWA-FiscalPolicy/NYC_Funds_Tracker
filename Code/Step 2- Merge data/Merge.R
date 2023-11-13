# This script can merge the raw datasets into one file.
# Read me before merging: 
   #1. confirm the url link below is correct
   #2. confirm the agency code list is correct


# budget_816 <- fread("~/Desktop/NYC_Fund_Tracker/Raw Data/Raw Data - Budget/budget_816_all.csv")
# budget_816 <- budget_816 %>%
#   filter(year != 2023)
# 
# budget_816_2023_raw <- fread("~/Desktop/816_2023_budget.csv")
# budget_816_2023 <- data.frame(V1=rep(0,nrow(budget_816_2023_raw)),
#                               agency=budget_816_2023_raw$Agency,
#                               year=budget_816_2023_raw$Year,
#                               department=budget_816_2023_raw$Department,
#                               expense_category=budget_816_2023_raw$`Expense Category`,
#                               budget_code=budget_816_2023_raw$`Budget Code`,
#                               budget_name=budget_816_2023_raw$`Budget Name`,
#                               adopted=budget_816_2023_raw$Adopted,
#                               modified=budget_816_2023_raw$Modified,
#                               encumbered=budget_816_2023_raw$Encumbered,
#                               cash_expense=budget_816_2023_raw$`Cash Expense`,
#                               pre_encumbered=budget_816_2023_raw$`Pre-Encumbered`,
#                               post_adjustment=budget_816_2023_raw$`Post Adjustments`,
#                               accrued_expense=budget_816_2023_raw$`Accrued Expense`
# )
# budget_816 <- data.frame(rbind(budget_816,budget_816_2023))
# write.csv(budget_816,"~/Desktop/budget_816_all.csv")  
  
library(RCurl)
library(tidyverse)
agencies_code <- c('068','260','125','069','806','071','816','801',"040")
# Revenue

url<- "https://raw.githubusercontent.com/ZoeyyyLyu/NYC_Fund_Tracker/main/Raw%20Data/Raw%20Data%20-%20Revenue/"
for (i in agencies_code){
  print(i)
  filename <- paste0("Revenue_",i,"_all.csv")
  c_url <- paste0(url,filename)
  if (i==agencies_code[1]){
    raw_budget <- read.csv(c_url)
  } else {
    current_data <- read.csv(c_url)
    raw_budget <- rbind(raw_budget,current_data)
  }
}
write.csv(raw_budget,"~/Desktop/raw_revenue.csv")


# Budget Expenditure
url<- "https://raw.githubusercontent.com/ZoeyyyLyu/NYC_Fund_Tracker/main/Raw%20Data/Raw%20Data%20-%20Budget/"
for (i in agencies_code){
  filename <- paste0("budget_",i,"_all.csv")
  c_url <- paste0(url,filename)
  if (i==agencies_code[1]){
    raw_budget <- read.csv(c_url)
  } else {
    current_data <- read.csv(c_url)
    raw_budget <- rbind(raw_budget,current_data)
  }
}
write.csv(raw_budget,"~/Desktop/raw_budget.csv")

