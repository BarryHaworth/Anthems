# Step 2: Perform Sentiment Analysis
# Load the previously captured data and perform sentiment analysis on it

library(dplyr)
library(tidytext)
library(textdata)
library(tidyr)
library(tidyverse)

PROJECT_DIR <- "c:/R/Anthems"
DATA_DIR    <- "c:/R/Anthems/data"

# Load the data
load(paste0(DATA_DIR,"/countries.RData"))

# Filter records with no anthem

countries <- countries %>% filter(nchar(lyrics) > 5)
head(countries$lyrics)

# Sentiment Analysis
# Number words, positive, negative
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

# Assign sentiment using each of the three databases
anthem_words_bing  <- anthem_words %>% left_join(bing_vector)
anthem_words_nrc   <- anthem_words %>% left_join(nrc_vector)
anthem_words_afinn <- anthem_words %>% left_join(afinn_vector)

#  Summarise sentiment by country
anthem_bing <- anthem_words_bing %>%
  group_by(country) %>% 
  count(sentiment) %>% # count the # of positive & negative words
  spread(sentiment, n, fill = 0) %>% # made data wide rather than narrow
  mutate(sentiment = positive - negative,
         sentiment_pct = sentiment/(positive+negative))

names(anthem_bing) <- c("country","bing_negative","bing_positive","bing_neutral",
                        "bing_sentiment","bing_sentiment_pct")

anthem_nrc <- anthem_words_nrc %>%
  group_by(country) %>% 
  count(sentiment) %>% # count the # of positive & negative words
  spread(sentiment, n, fill = 0) %>% # made data wide rather than narrow
  mutate(sentiment = positive - negative,
         sentiment_pct = sentiment/(positive+negative))

names(anthem_nrc) <- c("country","nrc_anger","nrc_anticipation","nrc_disgust","nrc_fear",
                       "nrc_joy","nrc_negative","nrc_positive","nrc_sadness",
                       "nrc_surprise","nrc_trust","nrc_neutral","nrc_sentiment","nrc_sentiment_pct")

anthem_afinn <- anthem_words_afinn %>%
  group_by(country) %>% 
  summarize(afinn_sentiment = mean(value, na.rm = TRUE)) %>% # Mean of Sentiment score
  mutate(afinn_sentiment_pct = afinn_sentiment/5)

# Combine all the sentiment ratings and the lyrics, etc.
anthems <- anthem_afinn %>%
  inner_join(anthem_bing, by="country") %>%
  inner_join(anthem_nrc, by="country") %>% 
  inner_join(countries, by="country")

head(anthems)

cor(anthems[c("afinn_sentiment_pct","bing_sentiment_pct","nrc_sentiment_pct")])

# Save Sentiment Words
save(anthem_words_bing ,file=paste0(DATA_DIR,"/anthem_words_bing.RData"))
save(anthem_words_nrc  ,file=paste0(DATA_DIR,"/anthem_words_nrc.RData"))
save(anthem_words_afinn,file=paste0(DATA_DIR,"/anthem_words_afinn.RData"))

# Save the Sentiment summaries
save(anthem_bing ,file=paste0(DATA_DIR,"/anthem_bing.RData"))
save(anthem_nrc  ,file=paste0(DATA_DIR,"/anthem_nrc.RData"))
save(anthem_afinn,file=paste0(DATA_DIR,"/anthem_afinn.RData"))

save(anthems,file=paste0(DATA_DIR,"/anthems.RData"))

