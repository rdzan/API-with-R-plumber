library(rvest) 
library(stringi) 

getNames <- function(letter = LETTERS[1], coreURL = "https://magia.onet.pl/imienniki/litera/"){
  print(letter) 
  page <- read_html(x = paste0(coreURL, letter)) 
  pageTableName <- page %>% 
    html_nodes(css = ".namesList") %>% 
    html_text() 
  
  tableName <- unlist(stri_extract_all_words(pageTableName)) 
  return(tableName) 
} 


allNames <- sapply(LETTERS, getNames) 
allNames <- unlist(allNames) 
allNames <- unique(allNames) 

saveRDS(allNames, "dict/allNames.RDS") 
