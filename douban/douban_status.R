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

url_base <- 'https://www.douban.com/people/'
id <- 64077663
url <- paste0(url_base,id,'/')

getguangbo <- function(i){
  print(i)
  urli <- paste0(url,'statuses?p=',i)
  chrome$navigate(urli)
  items <- chrome$findElements('class','stream-items')
  items <- unlist(geteletext(items))
  items <- strsplit(items,'\n')[[1]]
  items
}
myguangbo <- do.call(c,lapply(1:3,getguangbo))
myguangbo <- sapply(strsplit(myguangbo,' '),function(x){x[[1]]})
id <- names(sort(-table(myguangbo)))[1]

getguangbo2 <- function(i){
  print(i)
  urli <- paste0(url,'statuses?p=',i)
  chrome$navigate(urli)
  items <- chrome$findElements('class','stream-items')
  items <- unlist(geteletext(items))
  items <- strsplit(items,'\n')[[1]]
  start <- which(substr(items,1,nchar(id)+1) == paste0(id,' '))
  end <- c(start[-1]-1,length(items))
  lapply(1:length(start),function(j){
    items[start[j]:end[j]]
  })
}

n <- 9
myguangbo <- lapply(1:n,getguangbo2)
myguangbo <- do.call(c,myguangbo)
# save(myguangbo,file='myguangbo.rda')
# load('myguangbo.rda')
myguangbo <- lapply(myguangbo,function(x){
  x <- gsub('  ',' ',x)
})

h <- substr(sapply(myguangbo,function(x){x[[1]]}),1,nchar(id)+3)
myguangbo <- lapply(unique(h),function(x){
  myguangbo[h==x]
})
myguangbo[grep('看',unique(h))]
