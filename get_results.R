#This is ultimately aiming to be run on a weekly basis to update results file
# https://www.cyclingtimetrials.org.uk/find-results?page=7
#  has lists of events and results.
# Compare to existing data log
# a) new events,  
# b) falls within 10, 25,50,or 100 miles
# 
# Update the dates of events considered
# then follow links to valid event
#  search for Cambridge CC and take the relevant data if present

library(tidyverse)
library(rvest)
page <- read_html("https://www.cyclingtimetrials.org.uk/find-results")
events <-page %>% 
  html_element("table") %>% 
  html_table
events <- events[,-5]

links <-page %>% 
  html_element("table")  %>% html_elements("a") %>% 
  html_attr(name="href") %>%
  grep("race-results",. , value=TRUE)
events <- events %>% 
  mutate( date= as.Date(`Date/Time`, format= "%d %b %y"),
          link=links
          ) 

#  SO now need to compare to previous data, and see if you have to load the next page or whatever...

# if date is between 1-7 jan then do reset
dy <- Sys.Date() %>% as.Date %>% day
mth <- Sys.Date() %>% as.Date %>% month()
yr <- Sys.Date() %>% as.Date %>% year()
mth==1 & 1<= dy & dy<=7

# Do reset

# Check on how far back to read in results.
# How rapid is the website at putting up the results, and risks of missing a row that
# is entered late.  WIth a weekly update, go back a week earlier than the last date of check.
# Handle the event that the checks aren't sucessful- website down, code fails, github changes somethign...


