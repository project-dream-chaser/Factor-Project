library(purrr)
library(readxl)
library(reshape2)
library(tidyquant)
library(dplyr)
library(timetk)
library(tidyr)
library(broom)
library(xlsx)


#Import screened list from Morningstar export

Managed_Futures <- read_csv("Managed_Futures_20210910152904.csv") %>%
    select(Name, Ticker)
    
Managed_Futures <- Managed_Futures$Ticker %>% unique %>% na.omit
from.date <- (Sys.Date()-(lubridate::years(5)))

#Get Fund Prices

fund.prices <- Managed_Futures %>%
    tq_get(get  = "stock.prices",
           from = from.date,
           to   = Sys.Date())


#Calculate Fund Returns


fund.returns <- fund.prices %>%
    group_by(symbol) %>%
    tq_transmute(select     = adjusted, 
                 mutate_fun = periodReturn, 
                 period     = "monthly", 
                 col_rename = "fund.returns",
                 indexAt = "lastof") 




#Join Files for Regression



