
rm(list=ls())
library(rvest)

#Get Movie Urls
#2014 867233; 2015 836808; 2016 3516235

getdouban <- function(year){
  url1 <- paste0('https://www.douban.com/doulist/',year,'/?start=')
  url2 <- '&sort=seq&enc=utf-8'
  urli <- paste0(url1,0,url2)
  paginator <- read_html(urli,encoding='UTF-8') %>% html_nodes('.paginator') %>% html_text()
  paginator <- max(as.numeric(strsplit(paginator,'\n')[[1]]),na.rm=TRUE)
  i <- 1:paginator
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
    info <- webi %>% html_nodes('h1 span, #info, .rating_sum , .rating_num') %>% html_text()
    abstract <- paste(webi %>% html_nodes('#link-report span') %>% html_text(), collapse='')
    c(info,abstract)
  })

  return(movie.info)
}

system.time(x <- lapply(c(867233,836808,3516235),getdouban))


