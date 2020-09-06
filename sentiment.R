# Step 2: Perform Sentiment Anlaysis
# Load the previously captured data and perform sentiment analysis on it

library(dplyr)
library(tidytext)
library(textdata)

PROJECT_DIR <- "c:/R/Anthems"
DATA_DIR    <- "c:/R/Anthems/data"
TEXT_DIR    <- "c:/R/Anthems/text"

# Load the data
load(paste0(DATA_DIR,"/countries.RData"))

# Filter records with no anthem

countries <- countries %>% filter(nchar(lyrics) > 5)
head(countries$lyrics)

# Sentiment Analysis
# Number words, postitive, negative
# tidytext has three Lexicons:
# nrc:   Positive, Negative, anger, anticipation, disgust, fear, joy, sadness, surprise, and trust  <- Use this one
# bing:  positive, negative
# AFINN: score that runs between -5 and 5

# Split by Words
all_lyrics <- countries %>% 
  select(country, lyrics) %>%
  unnest_tokens(word, lyrics) 

filtered_lyrics <- all_lyrics %>% anti_join(stop_words)

# Assign Sentiment
# Download the Sentiment databases
bing_vector   <- get_sentiments("bing")
nrc_vector    <- get_sentiments("nrc")
afinn_vector  <- get_sentiments("afinn")

head(bing_vector)
head(nrc_vector)
head(afinn_vector)
