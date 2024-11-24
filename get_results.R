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
rm(list=ls())
library(tidyverse)
library(rvest)

# if date is between 1-7 jan then do reset
dy <- Sys.Date() %>% as.Date %>% day
mth <- Sys.Date() %>% as.Date %>% month()
yr <- Sys.Date() %>% as.Date %>% year()
if(mth==1 & 1<= dy & dy<=7){
  # Do reset
  stop_date <- as.Date(paste0(yr,"-01-01"))
  save(stop_date, file="stop_date.rds")
  all_times <- data.frame()
  # archive the old website record...
  # or maybe do the entire reset witin a github action..
  
  # save teh all_times
  # put copies of the files webpage.md and all_times.csv
  # into the wiki with appended year in the file name
  
  
}
# Check on how far back to read in results.
# How rapid is the website at putting up the results, and risks of missing a row that
# is entered late.  WIth a weekly update, go back a week earlier than the last date of check.
# Handle the event that the checks aren't sucessful- website down, code fails, github changes somethign...

#  If a page as any dates before the live stop-date then go on another page
#  update the stop-date to be the latest date less one week
load("stop_date.rds")
continue <- TRUE
new_times <- data.frame()


i <- 1
while( continue){
  message("lookup step 1",i)
  page <- read_html(paste0("https://www.cyclingtimetrials.org.uk/find-results?page=",i))
  message( "Post read")
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
 if( i ==1){ new_stop_date <- max(events$date) - weeks(1) }
  continue <- any(stop_date< events$date)
  i <- i+1
  #  now process the results on each link
  
  current <- events %>% 
    filter( Distance %in% c("10 miles","25 miles", "50 miles", "100 miles"),
            year(date)==yr) %>% # to cope with stop date being in last year in the first week.
            drop_na()
  
  
  if( 0< nrow(current)){
  for( j in 1:nrow(current)){
    
    
    url <- paste0("https://www.cyclingtimetrials.org.uk", current[j,"link"])
    message(url)
    page_event <- read_html(url)
    times <- page_event %>% 
      html_element("table") %>% 
      html_table
    times <- times[,-c(1)] %>%  
      select(Position, Machine, `First Name`,`Last Name`, Classification,
             Category, Club, Time) %>% 
      mutate(Position=as.character(Position),
             Time=as.character(Time),
             url=url,
             distance=current[j,"Distance"] %>% as.character
      ) %>% 
      filter( Club=="Cambridge CC")
    
    new_times <- bind_rows(new_times,times)
  }
 }
}
stop_date <- new_stop_date
save(stop_date, file="stop_date.rds")     
  #  SO now need to compare to previous data, and see if you have to load the next page or whatever...
  
  
  
##join up with the previous set of records

load( "all_times.rds")

all_times <- bind_rows(all_times, new_times) %>% 
  distinct()
save(all_times, file="all_times.rds")


###  now process the records to get the top 10 times at each distance
## create a web page from it. 
#renv::install("quarto")



quarto::quarto_render(output_file = paste0("Fastest Times ",yr,".md"))

write.csv(all_times, file=paste0("tt_result_scraping.wiki/all_results_",yr,".csv"), 
          row.names = FALSE)
