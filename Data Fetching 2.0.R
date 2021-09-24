library(tidyverse)
library(readxl)

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

dat <- readLines('factordata/F-F_Momentum_Factor.CSV')

keep <- as.numeric(substr(dat, 1, 6))
keep[is.na(keep)] <- 0
keep <- keep>10000
dat <- dat[keep]
dat <- read.csv(textConnection(dat), header = F)
colnames(dat) <- c('yearmon', 'MOM')
write.table(dat, 'factordata/mom.csv', sep = ',', row.names = F, col.names = T)

# Bond Factors

# Alternative Risk Factors

