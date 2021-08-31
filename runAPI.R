library(plumber) 

pr <- pr("plumber.R") 
pr %>% pr_run(port = 7494) 