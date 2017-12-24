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
main_url <- 'https://movie.douban.com'
chrome$navigate(main_url)
input <- chrome$findElement('name','search_text')
input$sendKeysToElement(list('神秘博士',key='enter'))

#Items
items <- chrome$findElements('class','title-text')
items_name <- geteletext(items)
items_href <- geteleattr(items,attr='href')

#urli
# urli <- items_href[[1]]
chrome$navigate(urli)
content <- chrome$findElements('class','indent')
geteletext(content)
