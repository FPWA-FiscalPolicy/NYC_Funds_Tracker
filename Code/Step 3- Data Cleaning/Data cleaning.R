# Data Cleaning
library(tidyverse)
library(data.table)
#Revenue- read the data
# 068- Administration for Children's Services; 260-Department of Youth and Community Development;
# 125-Department for the Aging; 069-Department of Social Services;806-Housing Preservation and Development;
# 071-Department of Homeless Services; 816-Department of Health and Mental Hygiene;801-Department of Small Business Services
# 040-Department of Education
Revenue_data <- fread('~/Desktop/Merged_data/raw_revenue.csv') # # of obs= 1103781
#construct a agency-code dictionary.
agency_code_dataframe <- data.frame(agency=unique(Revenue_data$agency),
                                    agency_code=c(c('068','260','125','069','806','071','816','801',"040")))
Revenue_data <- Revenue_data %>%
  filter(closing_classification_name != "Collected Unearned Revenue Roll" &
           closing_classification_name != "Accounts Left In Old Year")  %>%
  #filter(closing_classification_name != "Collected Unearned Revenue Roll")%>%
  filter(funding_class !="INTRA-CITY SALES")%>%
  filter(funding_class !="CAPITAL FUNDS - I.F.A.")%>%
  filter(fiscal_year<=2023 & fiscal_year>=2011) # # of obs= 930231

Revenue_data <- left_join(Revenue_data,agency_code_dataframe,by="agency")


# data_806 <-  Revenue_data %>%
#   filter(agency_code==806)%>%
#   filter(fiscal_year==2023)%>%
#   select(-c(budget_fiscal_year,fund_class,revenue_class))%>%
#   group_by(revenue_source,fiscal_year)%>%
#   summarize(sum_recognized=sum(recognized))
# write.csv(data_806,"~/Desktop/table.csv")

# agency_year_summary <- Revenue_data%>%
#   filter(fiscal_year==2023|fiscal_year==2022)%>%
#   group_by(agency,fiscal_year)%>%
#   summarize(sum_recognized=sum(recognized))



#Budget- read the data
Budget_data <- fread('~/Desktop/Merged_data/raw_budget.csv')
Budget_data <- left_join(Budget_data,agency_code_dataframe,by="agency")

Budget_data%>%
  group_by(agency,year)%>%
  summarise(sum_adopted=sum(adopted,na.rm=T),sum_modified=sum(modified,na.rm=T))


## Data Check