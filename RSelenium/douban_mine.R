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

# id <- 71066593
id <- 'count.pink'
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

######################
#movie
######################
out <- getmovies(p)
rlt <- lapply(out,function(x){
  do.call(rbind,lapply(strsplit(x,'\n'),function(x){
    if(length(x)==3){x <- c(x,NA)}
    return(x)
  }))
})
for(i in 1:3){
  rlt[[i]] <- data.frame(labs[[i]],rlt[[i]])
}
rlt_movie <- dplyr::arrange(do.call(rbind,rlt),desc(paste(X3)))

######################
#status
######################
chrome$navigate(url <- gsub('movie','www',url))
rlt <- list()
p <- 20
i <- 1
while(p>0){
 rlt[[i]] <- getguangbo(i)
 i <- i+1
}
rlt <- do.call(c,rlt)
h <- sapply(strsplit(rlt,'\n'),function(x){x[1]})
rlt_status <- rlt

######################
#save
######################

save(rlt_movie,rlt_status,file='rlt_douban_1225.rda')
