### Read me first #######
## This script can collect the budget data for a specific year.

# Loading the libraries ---------------------------------------------------
defaultW <- getOption("warn")
options(warn = -1)
library(data.table)
library("readxl")
library(httr)
library(xml2)
library(jsonlite)
library(tidyverse)
library(RCurl)
library(XML)
library(DescTools)
#setwd('[insert the your work directory here]')

# Scraping -----------------------------------------------------------
url<-"https://www.checkbooknyc.com/api"

#### create the list of nine agencies
# 068- Administration for Children's Services; 260-Department of Youth and Community Development;
# 125-Department for the Aging; 069-Department of Social Services;806-Housing Preservation and Development;
# 071-Department of Homeless Services; 816-Department of Health and Mental Hygiene;801-Department of Small Business Services
# 040-Department of Education
agencies_code <- c('068','260','125','069','806','071','816','801',"040")

# Specify the "YEAR" here
########### !!!!! Change line 30 to: years <- c(2024)
years <- c(2023)
#### create the table for both years and agencies
agency <- rep(agencies_code,each=length(years))
year <- rep(years,length(agencies_code))
agency_year <-data.frame(agency,year)

#### Revise the xml request and add the xml text to the table agency_year.
# Currenly, agency_year has three columns.
# Column 1 contains names of agencies; Column 2 contains budget fiscal years
# Column 3 contains the xml request for a specific agency at a specific year.(1-20000) The name of the agency and the year
# are the corresponding values in the first two columns.

agency_year <- agency_year %>%
  mutate(xml.request=paste("<request>
    <type_of_data>Budget</type_of_data>
    <records_from>1</records_from>
    <search_criteria>
        <criteria>
            <name>year</name>
            <type>value</type>
             <value>",year,"</value>
        </criteria>
        <criteria>
            <name>agency_code</name>
            <type>value</type>
             <value>",agency,"</value>
        </criteria>
       
    </search_criteria>
    <response_columns>
        <column>agency</column>
        <column>year</column>
        <column>department</column>
        <column>expense_category</column>
        <column>budget_code</column>
        <column>budget_name</column>
        <column>modified</column>
        <column>adopted</column>
        <column>pre_encumbered</column>
        <column>encumbered</column>
        <column>cash_expense</column>
        <column>post_adjustment</column>
        <column>accrued_expense</column>
    </response_columns>
</request>",sep=''))

# Column 4 contains the xml request for a specific agency at a specific year.(20001-40000) 
agency_year <- agency_year %>%
  mutate(xml.request.2=paste("<request>
  <type_of_data>Budget</type_of_data>
  <records_from>20001</records_from>
  <search_criteria>
        <criteria>
            <name>year</name>
            <type>value</type>
             <value>",year,"</value>
        </criteria>
        <criteria>
            <name>agency_code</name>
            <type>value</type>
             <value>",agency,"</value>
        </criteria>
       
    </search_criteria>
    <response_columns>
        <column>agency</column>
        <column>year</column>
        <column>department</column>
        <column>expense_category</column>
        <column>budget_code</column>
        <column>budget_name</column>
        <column>modified</column>
        <column>adopted</column>
        <column>pre_encumbered</column>
        <column>encumbered</column>
        <column>cash_expense</column>
        <column>post_adjustment</column>
        <column>accrued_expense</column>
    </response_columns>
</request>",sep=''))

# Column 5 contains the xml request for a specific agency at a specific year.(40001-60000) 
agency_year <- agency_year %>%
  mutate(xml.request.3=paste("<request>
  <type_of_data>Budget</type_of_data>
  <records_from>40001</records_from>
 <search_criteria>
        <criteria>
            <name>year</name>
            <type>value</type>
             <value>",year,"</value>
        </criteria>
        <criteria>
            <name>agency_code</name>
            <type>value</type>
             <value>",agency,"</value>
        </criteria>
       
    </search_criteria>
    <response_columns>
        <column>agency</column>
        <column>year</column>
        <column>department</column>
        <column>expense_category</column>
        <column>budget_code</column>
        <column>budget_name</column>
        <column>modified</column>
        <column>adopted</column>
        <column>pre_encumbered</column>
        <column>encumbered</column>
        <column>cash_expense</column>
        <column>post_adjustment</column>
        <column>accrued_expense</column>
    </response_columns>
</request>",sep=''))


# remove_duplicate <- function(data){
#   data <- as.data.frame(data)
#   data <- data %>%
#     #substitue all 0 in the adopted and modified columns into ''.
#     mutate(adopted = replace(adopted, adopted == 0, ''))%>%
#     mutate(modified = replace(modified, modified == 0, '')) %>%
#     distinct()
# }

Budget_in_specific_year <- function(first=1,last=13){
  summary_table <- c()
  for (i in first:last){
    print(i)
    xml.request <- agency_year[i,3]
    myheader=c(Connection="close", 
               'Content-Type' = "application/xml",
               'Content-length' =nchar(xml.request))
    data =  getURL(url = url,
                   postfields=xml.request,
                   httpheader=myheader,
                   verbose=TRUE)
    
    #Parses the HTML file, and generates an R structure representing the HTML tree.
    xmltext  <- xmlTreeParse(data, asText = TRUE,useInternalNodes=T)
    
    #Extract each column 
    agency <- xmlValue(xmltext["//agency"])
    year <- xmlValue(xmltext["//year"])
    department <- xmlValue(xmltext["//department"])
    expense_category <- xmlValue(xmltext["//expense_category"])
    budget_code <- xmlValue(xmltext["//budget_code"])
    budget_name <- xmlValue(xmltext["//budget_name"])
    adopted <- xmlValue(xmltext["//adopted"])
    modified <- xmlValue(xmltext["//modified"])
    encumbered <- xmlValue(xmltext["//encumbered"])
    cash_expense <- xmlValue(xmltext["//cash_expense"])
    pre_encumbered <- xmlValue(xmltext["//pre_encumbered"])
    post_adjustment <- xmlValue(xmltext["//post_adjustment"])
    accrued_expense <- xmlValue(xmltext["//accrued_expense"])
    
    # make another api call for record #20001- #40000
    if (length(agency)==20000){
      #Sys.sleep(5)
      xml.request <- agency_year[i,4]
      myheader=c(Connection="close", 
                 'Content-Type' = "application/xml",
                 'Content-length' =nchar(xml.request))
      data =  getURL(url = url,
                     postfields=xml.request,
                     httpheader=myheader,
                     verbose=TRUE)
      xmltext  <- xmlTreeParse(data, asText = TRUE,useInternalNodes=T)
      agency <- xmlValue(xmltext["//agency"])
      year <- xmlValue(xmltext["//year"])
      department <- xmlValue(xmltext["//department"])
      expense_category <- xmlValue(xmltext["//expense_category"])
      budget_code <- xmlValue(xmltext["//budget_code"])
      budget_name <- xmlValue(xmltext["//budget_name"])
      adopted <- xmlValue(xmltext["//adopted"])
      modified <- xmlValue(xmltext["//modified"])
      encumbered <- xmlValue(xmltext["//encumbered"])
      cash_expense <- xmlValue(xmltext["//cash_expense"])
      pre_encumbered <- xmlValue(xmltext["//pre_encumbered"])
      post_adjustment <- xmlValue(xmltext["//post_adjustment"])
      accrued_expense <- xmlValue(xmltext["//accrued_expense"])
    }
    
    # make another api call for record #40001- #60000
    if (length(agency)==40000){
      xml.request <- agency_year[i,5]
      myheader=c(Connection="close", 
                 'Content-Type' = "application/xml",
                 'Content-length' =nchar(xml.request))
      data =  getURL(url = url,
                     postfields=xml.request,
                     httpheader=myheader,
                     verbose=TRUE)
      xmltext  <- xmlTreeParse(data, asText = TRUE,useInternalNodes=T)
      agency <- xmlValue(xmltext["//agency"])
      year <- xmlValue(xmltext["//year"])
      department <- xmlValue(xmltext["//department"])
      expense_category <- xmlValue(xmltext["//expense_category"])
      budget_code <- xmlValue(xmltext["//budget_code"])
      budget_name <- xmlValue(xmltext["//budget_name"])
      adopted <- xmlValue(xmltext["//adopted"])
      modified <- xmlValue(xmltext["//modified"])
      encumbered <- xmlValue(xmltext["//encumbered"])
      cash_expense <- xmlValue(xmltext["//cash_expense"])
      pre_encumbered <- xmlValue(xmltext["//pre_encumbered"])
      post_adjustment <- xmlValue(xmltext["//post_adjustment"])
      accrued_expense <- xmlValue(xmltext["//accrued_expense"])
    }
    
    # Combine all columns
    current_summary_table <- cbind(
      agency,year,department,expense_category,budget_code, budget_name,adopted,
      modified,encumbered,cash_expense,pre_encumbered,post_adjustment,accrued_expense
    )
    summary_table <- rbind(summary_table,current_summary_table)
  }
  current_name <- paste("~/Desktop/raw_budget_",agency_year[i,2],'.csv',sep='')
  write.csv(summary_table,current_name)
  return(summary_table)
}

# Drivers: Scraping -----------------------------------------------------
table <- Budget_in_specific_year(1,9)
