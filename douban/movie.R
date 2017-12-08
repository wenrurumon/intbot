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
id <- 71066593
url <- paste0(url_base,id,'/')
labs <- c('collect','wish','do')

getmovie <- function(i,lab='collect',getp=F){
  # print(i)
  i <- (i-1)*15
  urli <- paste0(url,lab,'?start=',i)
  chrome$navigate(urli)
  p <- try(as.numeric(strsplit(geteletext(chrome$findElement('class','paginator'))[[1]],'[^0-9]')[[1]]))
  if(class(p)=="try-error"){p <- 1}
  if(getp){return(max(p,na.rm=T))}
  items <- chrome$findElements('class','item')
  geteletext(items)
}
p <- sapply(labs,getmovie,i=1,getp=T)
getmovies <- function(p){
  lapply(1:3,function(j){
    outj <- do.call(c,do.call(c,lapply(1:p[j],getmovie,names(p)[j],getp=F)))
    outj
  })
}
out <- getmovies(p)
rlt <- lapply(out,function(x){
  do.call(rbind,lapply(strsplit(x,'\n'),function(x){
    if(length(x)==3){x <- c(x,NA)}
    return(x)
  }))
})
substr(rlt[[1]][,1:3],1,10)
