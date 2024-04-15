# This script can merge the raw datasets into one file.
# Read me before merging: 
   #1. confirm the url link below is correct!
   #2. confirm the agency code list is correct
 
library(RCurl)
library(tidyverse)
agencies_code <- c('068','260','125','069','806','071','816','801',"040")

# Revenue
url<- "https://raw.githubusercontent.com/FPWA-FiscalPolicy/NYC_Funds_Tracker/main/RawData/Raw%20Data%20-%20Revenue/"

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
url<- "https://raw.githubusercontent.com/FPWA-FiscalPolicy/NYC_Funds_Tracker/main/RawData/Raw%20Data%20-%20Budget/"
for (i in agencies_code){
  print(i)
  filename <- paste0("raw_budget_",i,".csv")
  c_url <- paste0(url,filename)
  if (i==agencies_code[1]){
    raw_budget <- read.csv(c_url)
    raw_budget <- select(raw_budget,-1)
  } else {
    current_data <- read.csv(c_url)
    current_data <- select(current_data,-1)
    raw_budget <- rbind(raw_budget,current_data)
  }
}
write.csv(raw_budget,"~/Desktop/raw_budget.csv")
