library(stringi) 
library(data.table) 
library(feather) 

if(!dir.exists("dict")){
  dir.create("dict") 
}

source("functions/getCities.R") 
source("functions/getNames.R") 

n_order <- 12345 
keyLength <- 8 
allNames <- readRDS("dict/allNames.RDS") 
allCities <- readRDS("dict/cities.RDS")[, city] 

orders <- data.table(keyHash = stri_extract_all_regex(paste(sample(x = c(letters, LETTERS, 0:9), size = n_order * keyLength, replace = TRUE), collapse = ""), 
                                                  pattern = sprintf(".{%s}", keyLength))[[1]], 
                     name = sample(allNames, size = n_order, replace = TRUE), 
                     birthdate = sample(seq(as.Date('1970-01-01'), as.Date('2000-01-01'), by = "day"), n_order, replace = TRUE), 
                     city = sample(allCities, n_order, replace = TRUE), 
                     delete = 0) 

write_feather(x = orders, path = "orders.feather") 
