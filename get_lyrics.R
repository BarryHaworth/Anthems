# Step 1: Get the list of countries and their Anthems

#  This program is intended to harvest the lyrics and store them in text files.
# Lyrics will be taken from:
# https://lyrics.fandom.com/wiki/LyricWiki:Lists/National_Anthem

library(rvest)
library(dplyr)
library(rmutil)
library(openxlsx)
library(httr)

PROJECT_DIR <- "c:/R/Anthems"
DATA_DIR    <- "c:/R/Anthems/data"
TEXT_DIR    <- "c:/R/Anthems/text"

# Get List of Countries:

url <- 'https://lyrics.fandom.com/wiki/LyricWiki:Lists/National_Anthem'
webpage <- read_html(url)
c_list <- html_nodes(webpage,'ol')
c_data <- html_text(c_list)
country_list <- strsplit(c_data,"\n")
print(country_list)

# Put the list into a data frame and tidy it up
countries <- data.frame(country_list)
names(countries) <- "country"                   # Name the first field country
countries$country <- trimws(countries$country)  # remove leading and training blanks
countries$country <- gsub("&","And",countries$country)
countries$country <- gsub("'","",countries$country)

# Country names to drop
countries <- subset(countries,country != "Historic Austrian Anthems")
countries <- subset(countries,country != "Historic German anthems:")
countries <- subset(countries,country != "China")
countries <- subset(countries,country != "Historic anthem (until 1963)")
countries <- subset(countries,country != "Lithuanian SSR (Historic)")
countries <- subset(countries,country != "Grand Ducal anthem")

# Country names to update.

head(countries)

# save(countries,file=paste0(DATA_DIR,"/countries.RData"))



# Get the lyrics

# Next:  Loop through the countries and extract the lyrics.

countries["anthem_type"] <- ""
countries["url"] <- ""
countries["lyrics"] <- ""

for (c in 1:length(countries$country)){
# for (c in 26:27){
  print(paste("Reading country number ",c,countries$country[c]))
  country_ = gsub(" ","_",countries$country[c])
  address <- 'https://lyrics.fandom.com/wiki/National_'
  anthem    <- paste0(address,"Anthem:",country_)
  anthem_en <- paste0(address,"Anthem:",country_,"/en")
  anthem_english <- paste0(address,"Anthem:",country_,"_(English)")
  song      <- paste0(address,"Song:",country_)
  song_en   <- paste0(address,"Song:",country_,"/en")
  song_english   <- paste0(address,"Song:",country_,"_(English)")
  if (http_error(anthem_en) == FALSE) {
    countries$url[c] <- anthem_en
    countries$anthem_type[c] <- "Anthem, Translated"
  }
  else if (http_error(anthem_english) == FALSE){
    countries$url[c] <- anthem_english
    countries$anthem_type[c] <- "Anthem, Translated"
  }
  else if (http_error(anthem) == FALSE){
    countries$url[c] <- anthem
    countries$anthem_type[c] <- "Anthem"
  }
  else if (http_error(song_en) == FALSE){
    countries$url[c] <- song_en
    countries$anthem_type[c] <- "Song, Translated"
  }
  else if (http_error(song_english) == FALSE){
    countries$url[c] <- song_english
    countries$anthem_type[c] <- "Song, Translated"
  }
  else if (http_error(song) == FALSE){
    countries$url[c] <- song
    countries$anthem_type[c] <- "Song"
  }
  print(paste(countries$country[c],countries$anthem_type[c],"at URL",countries$url[c]))
  if (nchar(countries$url[c])>10){
    url <- countries$url[c]
    url <- toString(url)
    webpage <- read_html(url)
    c_list  <- html_nodes(webpage,'.lyricbox')
    lyrics  <- html_text(c_list[1])
    lyrics <- gsub("\n","",lyrics)
#    print(lyrics)
    countries$lyrics[c] <- lyrics
  }
  else {
    print(paste(countries$country[c],"Lyrics not found"))
  }
}

countries$lyrics <- gsub("([A-Z])", " \\1",countries$lyrics)  # Insert spaces in front of all capital letters.
countries$lyrics <- trimws(countries$lyrics)  # remove leading and training blanks

# Outstanding problems.
# Some anthems not found
# Some anthems do not pick up the english language version when it exists.

countries$anthem_type <- factor(countries$anthem_type)
summary(countries$anthem_type)

save(countries,file=paste0(DATA_DIR,"/countries.RData"))
write.xlsx(countries,paste0(DATA_DIR,"/countries.xlsx"))
