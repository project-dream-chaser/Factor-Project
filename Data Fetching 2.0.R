library(tidyverse)
library(readxl)

library(purrr)
library(readxl)
library(reshape2)
library(tidyquant)
library(dplyr)
library(timetk)
library(tidyr)
library(broom)
library(xlsx)

library(tidyverse)
library(tidyquant)
library(rvest)
library(httr)
library(plotly)
library(Quandl)
library(timetk)
library(reshape2)

# Data Downloading ----

# FF5 factors

temp <- tempfile()
download.file(
  "https://mba.tuck.dartmouth.edu/pages/faculty/ken.french/ftp/F-F_Research_Data_5_Factors_2x3_CSV.zip",
  temp
)
unzip(temp, exdir='factordata')

dat <- readLines('factordata/F-F_Research_Data_5_Factors_2x3.CSV')

keep <- as.numeric(substr(dat, 1, 6))
keep[is.na(keep)] <- 0
keep <- keep>10000
dat <- dat[keep]
dat <- read.csv(textConnection(dat), header = F)
colnames(dat) <- c('yearmon', 'MKT', 'SMB', 'HML', 'RMW', 'CMA', 'RF')
write.table(dat, 'factordata/ff5.csv', sep = ',', row.names = F, col.names = T)

# FF Momentum

temp <- tempfile()
download.file(
  "https://mba.tuck.dartmouth.edu/pages/faculty/ken.french/ftp/F-F_Momentum_Factor_CSV.zip",
  temp
)
unzip(temp, exdir='factordata')

datmom <- readLines('factordata/F-F_Momentum_Factor.CSV')

keep <- as.numeric(substr(datmom, 1, 6))
keep[is.na(keep)] <- 0
keep <- keep>10000
datmom <- datmom[keep]
datmom <- read.csv(textConnection(datmom), header = F)
colnames(datmom) <- c('yearmon', 'MOM')
FF5dat <- left_join(dat, datmom , 'yearmon')

# Bond Factors; 10 year treasury, 3 month T-Bill rate, corporate bond yield
Ten_yr<- tq_get("DGS10",get  = "economic.data",from=Sys.Date()-years(30)) %>% na.omit

# Alternative Risk Factors
TFFac <- read_csv('factordata/TF-Fac-6.CSV')

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

#Term and Credit
Ten_yr <- getSymbols.FRED("CPIAUNCS", env = "economic.data")
Ten_yr<- tq_get("DGS10",get  = "economic.data",from=Sys.Date()-years(30)) %>% na.omit
CorpYield <- tq_get("DBAA",get  = "economic.data",from=Sys.Date()-years(30)) %>% na.omit 
CreditSpreadTemp <- left_join(Ten_yr, CorpYield, 'date') 
CreditSpreadTemp <- as.Date('date',format="%d%m%Y")
CreditSpread <- CreditSpreadTemp %>% 
  dplyr:: mutate(spread = price.y - price.x)

#Combining data sets
Factor8 <- 
