# ============================================================================
# Title: Web Scraping Tables
# Description:
#   This script web scrapes links to get data tables.
# Input(s): URLs
# Output(s): .csv files
# Author: Timothy Tan
# Date: 2-7-2018
# ============================================================================

library(XML)
library(xml2)
library(rvest)
library(magrittr)
library(readr)
library(dplyr)

download.file(url = "http://feheroes.gamepedia.com/Level_40_stats_table", 
              destfile = 'data/heroes.html')
heroes <- as.data.frame(readHTMLTable('data/heroes.html', header = FALSE,
                                       stringsAsFactors = FALSE))

write_csv(heroes, "data/heroes.csv")

require(rvest)
url <- "http://feheroes.gamepedia.com/Level_40_stats_table"
doc <- read_html(url)
tbody <- doc %>% html_nodes("#mw-content-text > table > tr:not(:first-child)")

extract_tr <- function(tr){
  scope <- tr %>% html_children()
  c(scope[1:2] %>% html_text(),
    scope[3:length(scope)] %>% html_node("img") %>% html_attr("alt"))
}

res <- tbody %>% sapply(extract_tr)
res <- as.data.frame(t(res), stringsAsFactors = FALSE)

res = res[,-1]
heroes = heroes[,-1]
colnames(res) <- c("Name", "Class", "Movement", "HP", "ATK", 
                   "SPD", "DEF", "RES", "Total")
colnames(heroes) <- c("Name", "Class", "Movement", "HP", "ATK", 
                      "SPD", "DEF", "RES", "Total")

heroes$Class <- res$Class
heroes$Movement <- res$Movement

#filling in setsuna
setsuna <- c('Setsuna: Absent Archer', 'Icon Class Colorless Bow.png', 
             'Icon Move Infantry.png', 37, 28, 37, 22, 28, 147)
heroes[nrow(heroes) + 1,] <- setsuna
heroes <- heroes[order(heroes$Name),]

#type adjustment
heroes$HP <- as.integer(heroes$HP)
heroes$ATK <- as.integer(heroes$ATK)
heroes$SPD <- as.integer(heroes$SPD)
heroes$DEF <- as.integer(heroes$DEF)
heroes$RES <- as.integer(heroes$RES)
heroes$Total <- as.integer(heroes$Total)

#fix class and movement
for(i in 1:nrow(heroes)) {
  heroes$Class[i] <- gsub("\\.png", "", heroes$Class[i])
  heroes$Class[i] <- gsub("Icon Class ", "", heroes$Class[i])
  heroes$Movement[i] <- gsub("\\.png", "", heroes$Movement[i])
  heroes$Movement[i] <- gsub("Icon Move ", "", heroes$Movement[i])
}

#gamepress tiers
gamepress_tiers <- read_csv("data/gamepress_tiers.csv")

heroes$Tier <- gamepress_tiers$Tier

write_csv(heroes, "data/heroes.csv")

