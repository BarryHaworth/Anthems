# Step 2: Perform Sentiment Anlaysis
# Load the previously captured data and perform sentiment analysis on it

library(dplyr)
library(tidytext)
library(textdata)
library(tidyr)

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
anthem_words <- countries %>% 
  select(country, lyrics) %>%
  unnest_tokens(word, lyrics) 

# Filter stop words
anthem_words <- anthem_words %>% anti_join(stop_words)

# Assign Sentiment
# Download the Sentiment databases
bing_vector   <- get_sentiments("bing")
nrc_vector    <- get_sentiments("nrc")
afinn_vector  <- get_sentiments("afinn")

head(bing_vector)  # Positive or Negative
head(nrc_vector)   # Positive or Negative & others
head(afinn_vector) # Score

# Assign sentitment using each of the three databases
anthem_words_bing  <- anthem_words %>% left_join(bing_vector)
anthem_words_nrc   <- anthem_words %>% left_join(nrc_vector)
anthem_words_afinn <- anthem_words %>% left_join(afinn_vector)

#  Summarise sentiment by country
anthem_bing <- anthem_words_bing %>%
  group_by(country) %>% 
  count(sentiment) %>% # count the # of positive & negative words
  spread(sentiment, n, fill = 0) %>% # made data wide rather than narrow
  mutate(sentiment = positive - negative)
