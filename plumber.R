library(plumber) 
library(data.table) 
library(feather) 
library(jsonlite) 

# logging file 
logFilePath <- "log.txt" 
errorLogFilePath <- "errorLog.txt" 
usersKeyFilePath <- "usersKey.txt" 

ordersPath <- "orders.feather" 

keyLength <- 8 

readOrders <- function(ordersPath = ordersPath, onlyActive){
  orders <- read_feather(path = ordersPath) 
  setDT(orders) 
  if(onlyActive){
    orders <- orders[delete == 0] 
  }
  return(orders) 
}

checkUserKey <- function(userKey){
  usersKey <- fread(usersKeyFilePath, header = TRUE) 
  usersKey <- usersKey[key == userKey] 
  if(nrow(usersKey) == 0){
    login <- ""
  }else{
    login <- usersKey$login[1] 
  }
  
  return(login) 
} 

logging <- function(login, userKey, method, ts){
  if(login == ""){
    cat(sprintf('"%s" "%s" "%s"', ts, userKey, method), file = errorLogFilePath, sep = "\n", append = TRUE) 
    stop("Incorrect user key.") 
  }else{
    cat(sprintf('"%s" "%s" "%s"', ts, login, method), file = logFilePath, sep = "\n", append = TRUE) 
  }
} 


#' @apiTitle Example of Plumber API. 

#* Sample order. 
#* @param userKey API user authentication key. 
#* @get /sampleOrder
function(userKey){
  thisTime <- Sys.time() 
  login <- checkUserKey(userKey = userKey) 
  logging(login = login, userKey = userKey, method = "sampleOrder", ts = thisTime)
  
  orders <- readOrders(ordersPath = ordersPath, onlyActive = TRUE) 
  order <- orders[, sample(keyHash, size = 1)] 
  return(order) 
} 

#* Get order information based on order keyHash. 
#* @param orderKey Key of order. 
#* @param column Specific which column you want to get. Possible value are: 'name', 'birthdate', 'city'. 
#* @param userKey API user authentication key. 
#* @get /getOrder
function(orderKey, column = '["name", "birthdate", "city"]', userKey){
  thisTime <- Sys.time() 
  login <- checkUserKey(userKey = userKey) 
  logging(login = login, userKey = userKey, method = "getOrder", ts = thisTime)
  column <- fromJSON(txt = column) 
  
  orders <- readOrders(ordersPath = ordersPath, onlyActive = TRUE) 
  orders <- orders[keyHash == orderKey] 
  orders <- orders[, ..column] 
  return(orders) 
}

#* Delete order based on order keyHash. 
#* @param orderKey Key of order. 
#* @param userKey API user authentication key. 
#* @delete /deleteOrder
function(res, orderKey, userKey){
  thisTime <- Sys.time() 
  login <- checkUserKey(userKey = userKey) 
  logging(login = login, userKey = userKey, method = "deleteOrder", ts = thisTime)
  
  orders <- readOrders(ordersPath = ordersPath, onlyActive = FALSE) 
  orders[keyHash == orderKey, delete := 1] 
  write_feather(orders, path = ordersPath) 
  res$body <- sprintf("Order %s was successfully delete.", orderKey) 
  res 
} 

#* Add new order. 
#* @param name Name of consumer. 
#* @param birthdate Date of consumer b-day. 
#* @param city City of consumer. 
#* @param userKey API user authentication key. 
#* @post /addOrder
function(res, name, birthdate, city, userKey){
  thisTime <- Sys.time() 
  login <- checkUserKey(userKey = userKey) 
  logging(login = login, userKey = userKey, method = "addOrder", ts = thisTime)
  
  orders <- readOrders(ordersPath = ordersPath, onlyActive = FALSE) 
  orderKeyHash <- paste(sample(x = c(letters, LETTERS, 0:9), size = keyLength, replace = TRUE), collapse = "") 
  
  newOrder <- data.table(keyHash = orderKeyHash, 
                         name = name, 
                         birthdate = as.Date(birthdate), 
                         city = city, 
                         delete = 0) 
  
  orders <- rbindlist(list(orders, newOrder), use.names = TRUE) 
  write_feather(orders, path = ordersPath) 
  res$body <- sprintf("Create new order - order key: %s", orderKeyHash) 
  res 
} 
