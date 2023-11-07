# This script can merge the raw datasets into one file.
library(RCurl)
library(tidyverse)
# Revenue
# Budget Expenditure
agencies_code <- c('068','260','125','069','806','071','816','801',"040")
url<- "https://raw.githubusercontent.com/ZoeyyyLyu/NYC_Fund_Tracker/main/Raw%20Data/Raw%20Data%20-%20Budget/"
for (i in agencies_code){
  filename <- paste0("budget_",i,"_all.csv")
  c_url <- paste0(url,filename)
  print(c_url)
  #currentfile <-read.csv(c_url)
}

