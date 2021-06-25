library(DT)
library(tidytext)
library(dplyr)
library(stringr)
library(sentimentr)
library(ggplot2)
library(RColorBrewer)
library(readr)
library(SnowballC)
library(tm)
library(wordcloud)
library(reticulate)
library(crfsuite)
library(textdata)


reviews <- readr::read_csv(file = 'reviews.csv')

summary(reviews)


words <- reviews %>%
  select(c("id", "game", "score", "description")) %>%
  unnest_tokens(word, description) %>%
  filter(!word %in% stop_words$word, str_detect(word, "^[a-z']+$"))

datatable(head(words))

afinn <- get_sentiments("afinn") %>% mutate(word = wordStem(word))
reviews.afinn <- words %>%
  inner_join(afinn, by = "word")
head(reviews.afinn)

word_summary <- reviews.afinn %>%
  group_by(word) %>%
  summarise(mean_rating = mean(score), score = max(value), count_word = n()) %>%
  arrange(desc(count_word))
datatable(head(word_summary))


library(RColorBrewer)
wordcloud(words = word_summary$word, freq = word_summary$count_word, scale=c(5,.5), max.words=300, colors=brewer.pal(8, "Set2"))


good <- reviews.afinn %>%
  group_by(word) %>%
  summarise(mean_rating = mean(score), score = max(value), count_word = n()) %>%
  filter(mean_rating>mean(mean_rating)) %>%
  arrange(desc(mean_rating))
wordcloud(words = good$word, freq = good$count_word, scale=c(5,.5), max.words=100, colors=brewer.pal(8, "Set2"))


bad <- reviews.afinn %>%
  group_by(word) %>%
  summarise(mean_rating = mean(score), score = max(value), count_word = n()) %>%
  filter(count_word>1000) %>%
  filter(mean_rating<mean(mean_rating)) %>%
  arrange(mean_rating)
wordcloud(words = bad$word, freq = bad$count_word, scale=c(5,.5), max.words=100, colors=brewer.pal(8, "Set2"))

afinn <- get_sentiments("bing") %>% mutate(word = wordStem(word))
reviews.bing <- words %>%
  inner_join(bing, by = "word")
head(reviews.afinn)



library(syuzhet)
sentimento <- get_nrc_sentiment(reviews) %>%
  select(c("description")) %>%
   

barplot(colSums(sentimento),las = 2,ylab = "Quantidade",main = "Sentimento")
