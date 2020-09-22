# Step 3: Compare and Contrast

library(ggplot2)
library(dplyr)

PROJECT_DIR <- "c:/R/Anthems"
DATA_DIR    <- "c:/R/Anthems/data"

# nrc:   Positive, Negative, anger, anticipation, disgust, fear, joy, sadness, surprise, and trust  <- Use this one
# bing:  positive, negative
# AFINN: score that runs between -5 and 5

load(paste0(DATA_DIR,"/anthem_bing.RData"))
load(paste0(DATA_DIR,"/anthem_nrc.RData"))
load(paste0(DATA_DIR,"/anthem_afinn.RData"))

load(paste0(DATA_DIR,"/anthem_words_bing.RData"))
load(paste0(DATA_DIR,"/anthem_words_nrc.RData"))
load(paste0(DATA_DIR,"/anthem_words_afinn.RData"))

# Do a Boxplot of Word sentiment for selected countries

subset <- c("USA","Australia","New Zealand","United Kingdom","France")

anthem_words_subset <- anthem_words_afinn %>% filter(country %in% subset)

p <- ggplot(anthem_words_subset, aes(y=value, x=country))+
  geom_boxplot() + 
  labs(title="Sentiment Comparison by Country (Subset)") +
  xlab("Country") +ylab("Sentiment")
p

subset <- c("India","China","Taiwan","Vietnam")

anthem_words_subset <- anthem_words_afinn %>% filter(country %in% subset)

p <- ggplot(anthem_words_subset, aes(y=value, x=country))+
  geom_boxplot() + 
  labs(title="Sentiment Comparison by Country (Subset)") +
  xlab("Country") +ylab("Sentiment")
p

p <- ggplot(anthem_words_afinn, aes(y=value, x=region))+
  geom_boxplot() + 
  labs(title="Sentiment Comparison by Region") +
  xlab("Region") +ylab("Sentiment") + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
p

# Plots by Region
p <- ggplot(anthem_words_afinn %>% filter(region=='Asia'), aes(y=value, x=country))+
  geom_boxplot() + 
  labs(title="Sentiment Comparison in Asia") +
  xlab("Region") +ylab("Sentiment") + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
p

p <- ggplot(anthem_words_afinn %>% filter(region=='Africa'), aes(y=value, x=country))+
  geom_boxplot() + 
  labs(title="Sentiment Comparison in Africa") +
  xlab("Region") +ylab("Sentiment") + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
p

p <- ggplot(anthem_words_afinn %>% filter(region=='Americas'), aes(y=value, x=country))+
  geom_boxplot() + 
  labs(title="Sentiment Comparison in Americas") +
  xlab("Region") +ylab("Sentiment") + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
p

p <- ggplot(anthem_words_afinn %>% filter(region=='Europe'), aes(y=value, x=country))+
  geom_boxplot() + 
  labs(title="Sentiment Comparison in Europe") +
  xlab("Region") +ylab("Sentiment") + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
p

p <- ggplot(anthem_words_afinn %>% filter(region=='Oceania'), aes(y=value, x=country))+
  geom_boxplot() + 
  labs(title="Sentiment Comparison in Oceania") +
  xlab("Region") +ylab("Sentiment") + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
p

