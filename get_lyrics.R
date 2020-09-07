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

# Country names to drop.  These countries do not have anthems on the web page
droplist = c("Historic Austrian Anthems","Historic German anthems:","China",
             "Historic anthem (until 1963)","Lithuanian SSR (Historic)","Grand Ducal anthem",
             "Historic Bosnian Anthem","Estonian SSR (Historic)","German Democratic Republic")

# Drop the countries in the list
countries <- countries %>% filter(!(country %in% droplist))

head(countries)

# Manual updates to country names
countries$country[countries$country=="First Republic (unofficial)"] <- "First Republic Of Austria"

countries$country[countries$country=="Bosnia and Herzegovina (1995-1998)"] <-   "Bosnia And Herzegovina (1995-1998)"

countries$country[countries$country=="Peoples Republic of China (Mainland China)"] <- "China (PRR)"
countries$country[countries$country=="Republic of China (Taiwan)"] <- "China (Republic Of China)"
countries$country[countries$country=="Czech RepublicD-F"] <- "Czech Republic"
countries$country[countries$country=="National anthem"] <- "Denmark (Civil)"
countries$country[countries$country=="Royal anthem"] <- "Denmark (Royal)"
countries$country[countries$country=="FranceG-J"] <- "France"
countries$country[countries$country=="JapanK-N"] <- "Japan"
countries$country[countries$country=="Kiswahili"] <- "Kenya (Kiswahili)"
countries$country[countries$country=="English"] <- "Kenya (English)"
countries$country[countries$country=="Latvian SSR (Historic)"] <- "Latvian (SSR)"
countries$country[countries$country=="The Netherlands"] <- "Netherlands"
countries$country[countries$country=="Norway (current)O-S"] <- "Norway I"
countries$country[countries$country=="Soviet Union (Historic 1922 version)"] <- "Soviet Union 1922"
countries$country[countries$country=="Soviet Union (Historic 1944 version)"] <- "Soviet Union 1944"
countries$country[countries$country=="Soviet Union (Historic 1977 version)"] <- "Soviet Union 1977"
countries$country[countries$country=="Saint Kitts And Nevis"] <- "Saint Kitts & Nevis"
countries$country[countries$country=="Saint Vincent And the Grenadines"] <- "Saint Vincent And The Grenadines"
countries$country[countries$country=="Scotland (unofficial)"] <- "Scotland (Flower Of Scotland)"
countries$country[countries$country=="SyriaT-Z"] <- "Syria"

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
# Some anthems do not pick up the english language version when it exists.
# Some anthems seem to not have English lyrics.

countries$anthem_type <- factor(countries$anthem_type)
summary(countries$anthem_type)

save(countries,file=paste0(DATA_DIR,"/countries.RData"))
write.xlsx(countries,paste0(DATA_DIR,"/countries.xlsx"))
