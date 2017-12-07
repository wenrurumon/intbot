rm(list=ls())
geteletext <- function(...){
  x <- do.call(c,list(...))
  sapply(x,function(x){
    x$getElementText()
  })
}
geteleattr <- function(...,attr,ifunlist=F){
  x <- do.call(c,list(...))
  x <- sapply(x,function(x){
    x$getElementAttribute(attr)
  })
  if(ifunlist){
    return(unlist(x))
  } else {
    return(x)
  }
}

#Setup
library(RSelenium)
chrome <- remoteDriver(remoteServerAddr = "localhost" 
                       , port = 4444L
                       , browserName = "chrome")

#Get Browser
chrome$open()

###########################

#check guangbo
# url <- 'https://www.douban.com/mine/'
# chrome$navigate(url)
# url <- unlist(chrome$getCurrentUrl())

url_base <- 'https://movie.douban.com/people/'
id <- 64077663
url <- paste0(url_base,id,'/')
chrome$navigate(url)
