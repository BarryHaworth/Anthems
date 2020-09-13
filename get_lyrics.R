# Step 1: Get the list of countries and their Anthems

#  This program is intended to harvest the lyrics and store them in text files.
# Lyrics will be taken from:
# https://lyrics.fandom.com/wiki/LyricWiki:Lists/National_Anthem
# page part identified using SelectorGadget tool.

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

# Some anthems seem to not have English lyrics.
# Drop countries with no anthem or no English translation
# These countries do not have anthems on the web page
noanthem <-  c("Historic Austrian Anthems","Historic German anthems:","China",
             "Historic anthem (until 1963)","Lithuanian SSR (Historic)","Grand Ducal anthem",
             "Historic Bosnian Anthem","Estonian SSR (Historic)","German Democratic Republic",
             "Kenya (Kiswahili)","Kenya (English)","European Union")

# These countries have no English translation
notrans <- c("Ecuador","Venezuela","SyriaT-Z","Switzerland","Sweden",
            "Soviet Union (Historic 1922 version)","Soviet Union (Historic 1944 version)","Soviet Union (Historic 1977 version)",
            "Poland","Bosnia And Herzegovina","Bosnia and Herzegovina (1995-1998)",
            "Chile","Cornwall (national song, unofficial)","Cuba","Czech RepublicD-F",
            "Dominican Republic","Ecuador","El Salvador","Estonia",
            "Hungary","Italy","Latvia","Latvian SSR (Historic)","Liechtenstein","Luxemburg",
            "Madagascar","Malaysia","Norway (current)O-S","Panama")

countries <- countries %>% filter(!(country %in% c(noanthem,notrans)))

head(countries)

# Manual updates to country names
countries$country[countries$country=="First Republic (unofficial)"] <- "First Republic Of Austria"
countries$country[countries$country=="Peoples Republic of China (Mainland China)"] <- "China (PRR)"
countries$country[countries$country=="Republic of China (Taiwan)"] <- "China (Republic Of China)"
countries$country[countries$country=="National anthem"] <- "Denmark (Civil)"
countries$country[countries$country=="Royal anthem"] <- "Denmark (Royal)"
countries$country[countries$country=="FranceG-J"] <- "France"
countries$country[countries$country=="JapanK-N"] <- "Japan"
countries$country[countries$country=="Kiswahili"] <- "Kenya (Kiswahili)"
countries$country[countries$country=="English"] <- "Kenya (English)"
countries$country[countries$country=="The Netherlands"] <- "Netherlands"
countries$country[countries$country=="Norway (current)O-S"] <- "Norway I"
countries$country[countries$country=="Soviet Union (Historic 1922 version)"] <- "Soviet Union 1922"
countries$country[countries$country=="Soviet Union (Historic 1944 version)"] <- "Soviet Union 1944"
countries$country[countries$country=="Soviet Union (Historic 1977 version)"] <- "Soviet Union 1977"
countries$country[countries$country=="Saint Kitts And Nevis"] <- "Saint Kitts & Nevis"
countries$country[countries$country=="Saint Vincent And the Grenadines"] <- "Saint Vincent And The Grenadines"
countries$country[countries$country=="Scotland (unofficial)"] <- "Scotland (Flower Of Scotland)"

# Get the lyrics:  Loop through the countries and extract the lyrics.

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

# Outstanding problems.
# Some anthems do not pick up the english language version when it exists.

# Manually correct selected 
countries$lyrics[countries$country=="Austria"] <- "Land of mountains, land by the stream, Land of fields, land of cathedrals, Land of hammers, with a promising future, Home to great daughters and sons, A nation highly blessed with beauty, Much-praised Austria, Much-praised Austria! Strongly feuded for, fiercely hard-fought for, Thou liest in the middle of the continent Like a strong heart, Since the early days of the ancestors thou hast Borne the burden of a high mission, Much tried Austria, Much tried Austria.  Bravely towards the new ages See us striding, free, and faithful, Assiduous and full of hope, Unified, in jubilation choirs, let us Pledge allegiance to thee, Fatherland Much beloved Austria, Much beloved Austria."
countries$lyrics[countries$country=="Germany"] <- "Unity and justice and freedom For the German fatherland! For these let us all strive Brotherly with heart and hand! Unity and justice and freedom Are the pledge of fortune; Flourish in this fortune's blessing, Flourish, German fatherland!  Flourish in this fortune's blessing, Flourish, German fatherland!"
countries$lyrics[countries$country=="Brittany (national song, unofficial)"] <- "Us, Bretons by heart, love our true country! Armorica, famous throughout the world. Without any fear in battle, our so good fathers, Shed their blood for you. Brittany, my country that I love, As long as the sea, like a wall surrounds you, Shall my country be free! Brittany, land of the Old Saints, land of the bards, There is no other country that I love as much. Every mountain, every glen is the dearest to my heart, Many an heroic Breton are resting there. The Bretons are a strong and tough people. No people under the skies is as brave as them, Whether they may sing a sad gwerz or a nice song. Oh, my so beautiful country! If in the past Brittany may have been defeated in battle, Her language will always remain well alive, Her flaming heart is still beating in her chest : You are now awakened, my dear Brittany!"
countries$lyrics[countries$country=="South Africa"] <- "Land of mountains, land by the stream, Land of fields, land of cathedrals, Land of hammers, with a promising future, Home to great daughters and sons, A nation highly blessed with beauty, Much-praised Austria, Much-praised Austria! Strongly feuded for, fiercely hard-fought for, Thou liest in the middle of the continent Like a strong heart, Since the early days of the ancestors thou hast Borne the burden of a high mission, Much tried Austria, Much tried Austria.  Bravely towards the new ages See us striding, free, and faithful, Assiduous and full of hope, Unified, in jubilation choirs, let us Pledge allegiance to thee, Fatherland Much beloved Austria, Much beloved Austria."
countries$lyrics[countries$country=="Israel"] <- "As long as deep in the heart, The soul of a Jew yearns, And towards the East An eye looks to Zion, Our hope is not yet lost, The hope of two thousand years, To be a free people in our land, The land of Zion and Jerusalem."
  
# Final Clean up
countries$lyrics <- gsub("([A-Z])", " \\1",countries$lyrics)  # Insert spaces in front of all capital letters.
countries$lyrics <- trimws(countries$lyrics)  # remove leading and training blanks


countries$anthem_type <- factor(countries$anthem_type)
summary(countries$anthem_type)

save(countries,file=paste0(DATA_DIR,"/countries.RData"))
write.xlsx(countries,paste0(DATA_DIR,"/countries.xlsx"))
