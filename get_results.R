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
  