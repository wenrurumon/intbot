
rm(list=ls())
library(rvest)

#Get Movie Urls

url1 <- 'https://www.douban.com/doulist/867233/?start='
url2 <- '&sort=seq&enc=utf-8'
i <- 1:2
urls <- paste0(url1,(i-1)*25,url2)

movie.urls <- lapply(urls,function(urli){
  print(urli)
  webi <- read_html(urli,encoding='UTF-8')
  (infoi <- webi %>% html_nodes('.title a') %>% html_attr('href'))
})
movie.urls <- do.call(c,movie.urls)

#Get Movie info

movie.info <- lapply(movie.urls,function(urli){
  print(urli)
  webi <- read_html(urli,encoding='UTF-8')
  info <- webi %>% html_nodes('#info') %>% html_text()
  text <- webi %>% html_nodes('#link-report span') %>% html_text()
  score <- webi %>% html_nodes('.rating_sum , .rating_num') %>% html_text()
  list(info=info,text=text,score=score)  
})
