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
url <- 'https://www.douban.com/mine/'
chrome$navigate(url)
url <- unlist(chrome$getCurrentUrl())

# url_base <- 'https://www.douban.com/people/'
# id <- 64077663
# url <- paste0(url_base,id,'/')

getguangbo <- function(i){
  urli <- paste0(url,'statuses?p=',i)
  chrome$navigate(urli)
  # items <- chrome$findElements('class','status-item')
  items <- chrome$findElements('class','new-status')
  items <- unlist(geteletext(items))
  p <<- length(items)
  print(paste(i,p))
  items
}
rlt <- list()
p <- 20
i <- 1
while(p>0){
 rlt[[i]] <- getguangbo(i)
 i <- i+1
}
rlt <- do.call(c,rlt)
h <- sapply(strsplit(rlt,'\n'),function(x){x[1]})

