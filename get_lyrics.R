# Step 1: Get the Anthems

#  This program is intended to harvest the lyrics and store them in text files.
# Lyrics will be taken from:
# https://lyrics.fandom.com/wiki/LyricWiki:Lists/National_Anthem

library(rvest)
library(dplyr)
library(rmutil)

PROJECT_DIR <- "c:/R/Anthems"
DATA_DIR    <- "c:/R/Anthems/data"
TEXT_DIR    <- "c:/R/Anthems/text"

# Get List of Countries:

url <- 'https://lyrics.fandom.com/wiki/LyricWiki:Lists/National_Anthem'
webpage <- read_html(url)
c_list <- html_nodes(webpage,'ol')
c_data <- html_text(c_list)
country_list <- strsplit(c_data,"\n ")
print(country_list)

# Put the list into a data frame and tidy it up
countries <- data.frame(country_list)
names(countries) <- "country"
countries$country <- trimws(countries$country)

head(countries)

# Create links to Anthem lyrics
# Note: probablyu don't need to save them
countries$anthem    <- paste0('https://lyrics.fandom.com/wiki/National_Anthem:',
                            gsub(" ","_",countries$country))
countries$anthem_en <- paste0('https://lyrics.fandom.com/wiki/National_Anthem:',
                            gsub(" ","_",countries$country),"/en")
countries$song    <- paste0('https://lyrics.fandom.com/wiki/National_Song:',
                            gsub(" ","_",countries$country))
countries$song_en <- paste0('https://lyrics.fandom.com/wiki/National_Song:',
                            gsub(" ","_",countries$country),"/en")

save(countries,file=paste0(DATA_DIR,"/countries.RData"))

# Get the lyrics

# Test with Australia for an English language version
url <- countries %>% filter(country == "Australia") %>% select(anthem)
url <- toString(url)
webpage <- read_html(url)
c_list  <- html_nodes(webpage,'.lyricbox')
lyrics  <- html_text(c_list[1])
lyrics <- gsub("\n","",lyrics)
print(lyrics)

# Test with Afganistan for a non-English version
url <- countries %>% filter(country == "Afghanistan") %>% select(anthem_en)
url <- toString(url)
webpage <- read_html(url)
c_list  <- html_nodes(webpage,'.lyricbox')
lyrics  <- html_text(c_list[1])
lyrics <- gsub("\n","",lyrics)
print(lyrics)

# Next:  Loop through the countries and extract the lyrics.

# for (c in 1:length(countries$country)){
for (c in 10:15){
  print(paste("Reading country number ",c,countries$country[c]))
  url <- countries$anthem[c]
  url <- toString(url)
  webpage <- read_html(url)
  c_list  <- html_nodes(webpage,'.lyricbox')
  lyrics  <- html_text(c_list[1])
  lyrics <- gsub("\n","",lyrics)
  print(lyrics)
  countries$lyrics[c] <- lyrics
}

save(countries,file=paste0(DATA_DIR,"/countries.RData"))
