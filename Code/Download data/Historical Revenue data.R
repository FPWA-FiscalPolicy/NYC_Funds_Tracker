### Read me first #######
## This script can collect all the historical revenue data from FY 2011

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
#### create the list of budget fiscal years
# add number 2024 for FY24 update 
years <- c(2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022,2023)
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
  <type_of_data>Revenue</type_of_data>
  <records_from>1</records_from>
  <search_criteria>
  <criteria>
  <name>budget_fiscal_year</name>
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
  <column>budget_fiscal_year</column>
  <column>fiscal_year</column>
  <column>fund_class</column>
  <column>funding_class</column>
  <column>revenue_category</column>
  <column>revenue_source</column>
  <column>revenue_class</column>
  <column>adopted</column>
  <column>modified</column>
  <column>recognized</column>
  <column>closing_classification_name</column>
  </response_columns>
  </request>",sep=''))

# Column 4 contains the xml request for a specific agency at a specific year.(20001-40000) 
agency_year <- agency_year %>%
  mutate(xml.request.2=paste("<request>
  <type_of_data>Revenue</type_of_data>
  <records_from>20001</records_from>
  <search_criteria>
  <criteria>
  <name>budget_fiscal_year</name>
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
  <column>budget_fiscal_year</column>
  <column>fiscal_year</column>
  <column>fund_class</column>
  <column>funding_class</column>
  <column>revenue_category</column>
  <column>revenue_source</column>
  <column>revenue_class</column>
  <column>adopted</column>
  <column>modified</column>
  <column>recognized</column>
  <column>closing_classification_name</column>
  </response_columns>
  </request>",sep=''))

# Column 5 contains the xml request for a specific agency at a specific year.(40001-60000) 
agency_year <- agency_year %>%
  mutate(xml.request.3=paste("<request>
  <type_of_data>Revenue</type_of_data>
  <records_from>40001</records_from>
  <search_criteria>
  <criteria>
  <name>budget_fiscal_year</name>
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
  <column>budget_fiscal_year</column>
  <column>fiscal_year</column>
  <column>fund_class</column>
  <column>funding_class</column>
  <column>revenue_category</column>
  <column>revenue_source</column>
  <column>revenue_class</column>
  <column>adopted</column>
  <column>modified</column>
  <column>recognized</column>
  <column>closing_classification_name</column>
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

Historical_Revenue_Data <- function(first,last){
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
    revenue_category <- xmlValue(xmltext["//revenue_category"])
    revenue_source <- xmlValue(xmltext["//revenue_source"])
    fund_class <- xmlValue(xmltext["//fund_class"])
    funding_class <- xmlValue(xmltext["//funding_class"])
    revenue_class <- xmlValue(xmltext["//revenue_class"])
    budget_fiscal_year <- xmlValue(xmltext["//budget_fiscal_year"])
    fiscal_year <- xmlValue(xmltext["//fiscal_year"])
    adopted <- xmlValue(xmltext["//adopted"])
    modified <- xmlValue(xmltext["//modified"])
    recognized <- xmlValue(xmltext["//recognized"])
    closing_classification_name <- xmlValue(xmltext["//closing_classification_name"])
    
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
      agency <- c(agency,xmlValue(xmltext["//agency"]))
      revenue_category <- c(revenue_category,xmlValue(xmltext["//revenue_category"]))
      revenue_source <- c(revenue_source,xmlValue(xmltext["//revenue_source"]))
      fund_class <- c(fund_class,xmlValue(xmltext["//fund_class"]))
      funding_class <- c(funding_class,xmlValue(xmltext["//funding_class"]))
      revenue_class <- c(revenue_class,xmlValue(xmltext["//revenue_class"]))
      budget_fiscal_year <- c(budget_fiscal_year,xmlValue(xmltext["//budget_fiscal_year"]))
      fiscal_year <- c(fiscal_year,xmlValue(xmltext["//fiscal_year"]))
      adopted <- c(adopted,xmlValue(xmltext["//adopted"]))
      modified <- c(modified,xmlValue(xmltext["//modified"]))
      recognized <- c(recognized,xmlValue(xmltext["//recognized"]))
      closing_classification_name <- c(closing_classification_name,xmlValue(xmltext["//closing_classification_name"]))
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
      agency <- c(agency,xmlValue(xmltext["//agency"]))
      revenue_category <- c(revenue_category,xmlValue(xmltext["//revenue_category"]))
      revenue_source <- c(revenue_source,xmlValue(xmltext["//revenue_source"]))
      fund_class <- c(fund_class,xmlValue(xmltext["//fund_class"]))
      funding_class <- c(funding_class,xmlValue(xmltext["//funding_class"]))
      revenue_class <- c(revenue_class,xmlValue(xmltext["//revenue_class"]))
      budget_fiscal_year <- c(budget_fiscal_year,xmlValue(xmltext["//budget_fiscal_year"]))
      fiscal_year <- c(fiscal_year,xmlValue(xmltext["//fiscal_year"]))
      adopted <- c(adopted,xmlValue(xmltext["//adopted"]))
      modified <- c(modified,xmlValue(xmltext["//modified"]))
      recognized <- c(recognized,xmlValue(xmltext["//recognized"]))
      closing_classification_name <- c(closing_classification_name,xmlValue(xmltext["//closing_classification_name"]))
    }
    
    # Combine all columns
    current_summary_table <- cbind(
      agency,revenue_category,revenue_source,fund_class,funding_class, revenue_class,budget_fiscal_year,
      fiscal_year,adopted,modified,recognized,closing_classification_name
    )
    summary_table <- rbind(summary_table,current_summary_table)
  }
  current_name <- paste("~/Desktop/Revenue_",agency_year[i,1],'_all.csv',sep='')
  write.csv(summary_table,current_name)
  return(summary_table)
}

# Drivers: Scraping -----------------------------------------------------
# 068-Administration for Children's Services, 2011 to 2022
# change "table_068 <- Historical_Revenue_Data(1,13)" to "table_068 <- Historical_Revenue_Data(1,14)" for FY24 update
# change "table_068 <- Historical_Revenue_Data(1,13)" to "table_068 <- Historical_Revenue_Data(1,15)" for FY25 update
table_068 <- Historical_Revenue_Data(1,13)
# 260-Department of Youth and Community Development, 2011 to 2022
# change "table_260 <- Historical_Revenue_Data(14,26)" to "table_260 <- Historical_Revenue_Data(15,28)" for FY24 update
# change "table_260 <- Historical_Revenue_Data(14,26)" to "table_260 <- Historical_Revenue_Data(16,29)" for FY25 update
table_260 <- Historical_Revenue_Data(14,26)
# 125-Department for the Aging, 2011 to 2022
table_125 <- Historical_Revenue_Data(27,39)
# 069-Department of Social Services
table_069 <- Historical_Revenue_Data(40,52)
# 806-Housing Preservation and Development
table_806 <- Historical_Revenue_Data(53,65)
# 071-Department of Homeless Services
table_071 <- Historical_Revenue_Data(66,78)
# 816-Department of Health and Mental Hygiene
table_816 <- Historical_Revenue_Data(79,91)
# 801-Department of Small Business Services
table_801 <- Historical_Revenue_Data(92,104)
# 040-Department of Education
table_040 <- Historical_Revenue_Data(105,117)
