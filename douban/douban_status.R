
rm(list=ls())

#Functions
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
'
navigate
findElement
sendKeysToActiveElement
getCurrentUrl
'

#Setup
library(RSelenium)
chrome <- remoteDriver(remoteServerAddr = "localhost" 
                      , port = 4444L
                      , browserName = "chrome")

#Get Browser
  chrome$open()

#Login Douban
  url <- 'http://www.douban.com'
  #username <- 
  #passwd <- 
  chrome$navigate(url)
  chrome$findElement('xpath','//*[@id="form_email"]')
  chrome$sendKeysToActiveElement(list(key='tab'))
  chrome$sendKeysToActiveElement(list(username,key='tab',passwd))
  chrome$sendKeysToActiveElement(key='enter')

#check reminder
  reminder <- chrome$findElements('class','lnk-remind')
  doumail <- chrome$findElements('id','top-nav-doumail-link')
  # sapply(doumail,function(x){x$getElementText()})
  geteletext(doumail,reminder)
  # sapply(doumail, function(x) x$getElementAttribute("href"))
  geteleattr(doumail,reminder,attr='href')
  url <- geteleattr(doumail,attr='href',ifunlist=T)
  chrome$navigate(url)

#check guangbo
  url <- 'https://www.douban.com/mine/'
  chrome$navigate(url)
  url <- unlist(chrome$getCurrentUrl())
  
  getguangbo <- function(i){
    print(i)
    urli <- paste0(url,'statuses?p=',i)
    chrome$navigate(urli)
    items <- chrome$findElements('class','stream-items')
    items <- unlist(geteletext(items))
    items <- strsplit(items,'\n')[[1]]
    end <- grep('   删除',items)
    start <- c(1,end[-length(end)]+1)
    lapply(1:length(end),function(j){
      items[start[j]:end[j]]
    })
  }
  
  myguangbo <- lapply(1:5,getguangbo)
  

    
