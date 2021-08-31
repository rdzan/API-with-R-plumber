library(rvest) 
library(stringi) 
library(data.table) 

cities <- read_html("https://www.polskawliczbach.pl/Miasta") %>% 
  html_nodes("table") %>% 
  html_table(header = TRUE) %>% 
  `[[`(1) 

names(cities) <- c("id", "city", "district", "voivodeship", "population", "area") 

setDT(cities) 
saveRDS(cities, file = "dict/cities.RDS")  
