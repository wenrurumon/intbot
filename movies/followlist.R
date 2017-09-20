
library(rvest)
rm(list=ls())

#first page

prod <- 25845401; key <- 'collections'

url <- paste0('https://movie.douban.com/subject/',prod,'/',key)
fp <- function(url){
  w <- read_html(url,encoding='UTF-8')
  url2 <- unique(w %>% html_nodes('#collections_tab a') %>% html_attr('href'))
  usr <- grep('people',url2,value=T)
    usr <- gsub('https://www.douban.com/people/','',usr)
    usr <- substr(usr,1,nchar(usr)-1)
  url <- url2[!grepl('people',url2)]
  list(usr=usr,url=url[length(url)])
}

#check next page

tmp <- fp(url)
usrs <- tmp$usr
i <- 1
while((!is.null(tmp$url)&length(tmp$usr)>0)){
  print(i<<-i+1)
  url <- tmp$url
  tmp <- fp(url)
  usrs <- c(usrs,tmp$usr)
}


