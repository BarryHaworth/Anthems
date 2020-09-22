# Step 1: Get the list of anthemworld and their Anthems

#  This program is intended to harvest the lyrics and store them in text files.
# Lyrics will be taken from:
# https://lyrics.fandom.com/wiki/LyricWiki:Lists/National_Anthem
# page part identified using SelectorGadget tool.
# Update:
# Found http://anthemworld.com/ website with a more comprehensive 
# collection of English language translations of national anthems
# Attempted to rip the contents, but ended up simpler to
# Cut and past into a spreadsheet

library(rvest)
library(dplyr)
library(rmutil)
library(openxlsx)
library(httr)

PROJECT_DIR <- "c:/R/Anthems"
DATA_DIR    <- "c:/R/Anthems/data"

# Get List of Countries from Anthemworld.com:
anthemworld <- read.xlsx(paste0(DATA_DIR,"/anthemworld_lyrics.xlsx")) 
names(anthemworld) 

anthemworld$lyrics <- gsub('\n',' ',anthemworld$lyrics)  # Replace \n with spaces.
#anthemworld$lyrics <- gsub("([A-Z])", " \\1",anthemworld$lyrics)  # Insert spaces in front of all capital letters.
anthemworld$lyrics <- trimws(anthemworld$lyrics)                  # remove leading and training blanks

head(anthemworld)

# Final Clean up

anthemworld$region <- factor(anthemworld$region)
summary(anthemworld$region)

save(anthemworld,file=paste0(DATA_DIR,"/anthemworld.RData"))
write.xlsx(anthemworld,paste0(DATA_DIR,"/anthemworld_anthems.xlsx"))
