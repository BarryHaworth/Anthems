# Step 1: Get the list of anthemworld and their Anthems

#  This program is intended to harvest the lyrics and store them in text files.
# Lyrics will be taken from:
# https://lyrics.fandom.com/wiki/LyricWiki:Lists/National_Anthem
# page part identified using SelectorGadget tool.
# Update:
# Found http://anthemworld.com/ website with a more comprehensive 
# collection of English language translations of national anthems

library(rvest)
library(dplyr)
library(rmutil)
library(openxlsx)
library(httr)

PROJECT_DIR <- "c:/R/Anthems"
DATA_DIR    <- "c:/R/Anthems/data"

# Get List of Countries from Anthemworld.com:
anthemworld <- read.xlsx(paste0(DATA_DIR,"/anthemworld.xlsx")) 
names(anthemworld) <- c("region","country")
# anthemworld <- anthemworld[anthemworld$country!='Cote dvoire',] # Drop this one for now.

anthemworld$url <- paste0("http://anthemworld.com/",gsub(" ","_",anthemworld$country),".html")


head(anthemworld)

# Manual updates to country names
# Not needed.  Updates are made in the spreadsheet

# Get the lyrics:  Loop through the countries and extract the lyrics.

anthemworld["lyrics"] <- ""

# test read
webpage <- read_html(anthemworld$url[3])
c_list  <- html_nodes(webpage,'dl')
lyrics  <- html_text(c_list[1])
print(lyrics)

for (c in 1:length(anthemworld$country)){
  print(paste(c,anthemworld$country[c],anthemworld$url[c]))
  webpage <- read_html(anthemworld$url[c])
  c_list  <- html_nodes(webpage,'dl')
  lyrics  <- html_text(c_list[1])
  #    print(lyrics)
  anthemworld$lyrics[c] <- lyrics
}

# Outstanding problems.
# Some anthems do not pick up the english language version when it exists.

# Manually correct selected 

# Final Clean up

anthemworld$region <- factor(anthemworld$region)
summary(anthemworld$region)

save(anthemworld,file=paste0(DATA_DIR,"/anthemworld.RData"))
write.xlsx(anthemworld,paste0(DATA_DIR,"/anthemworld_anthems.xlsx"))
