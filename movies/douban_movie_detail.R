
#########################
# Setup
#########################

library(RSelenium)
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

chrome <- remoteDriver(remoteServerAddr = "localhost" 
                       , port = 4444L
                       , browserName = "chrome")
chrome$open()

#########################
# Macro
#########################

#Get movie url
get_movie_url <- function(keyword){
  chrome$navigate('http://movie.douban.com')
  input <- chrome$findElement('name',"search_text")
  #keyword <- '三生三世'
  input$sendKeysToElement(list(keyword,key='enter'))
  #Get subject slide
  subs <- chrome$findElements('tag name','a')
  subtext <- unlist(geteletext(subs))
  subs <- subs[grepl(keyword,subtext)]
  subtext <- unlist(geteletext(subs))
  subhref <- unlist(geteleattr(subs,attr='href'))
  subs <- cbind(subtext,subhref)[grepl('subject/',subhref)&nchar(subtext)>0,,drop=F]
  #the Subject
  url <- subs[1,2]
  list(url=url,candidate=subs)
}

get_movie_info <- function(url){
  chrome$navigate(url)
  info <- strsplit(geteletext(chrome$findElement('id','info'))[[1]],'\n')
  intro <- geteletext(chrome$findElement('id','link-report'))[[1]]
  #short comments
  cmts <- lapply(0:4,function(i){
    shorts <- paste0(url,'comments?start=',i*20,'&limit=20&sort=new_score&status=P&percent_type=')
    chrome$navigate(shorts)
    cmts <- chrome$findElements('class','comment')
    if(length(cmts)==0){return(NULL)}
    cmtext <- do.call(rbind,strsplit(unlist(geteletext(cmts)),'\n'))
    cmturl <- unlist(geteleattr(chrome$findElements('tag name','a'),attr='href'))
    cmturl <- unique(cmturl[grep('people',cmturl)])
    cmti <- cbind(cmtext,cmturl)
    cmti
  })
  cmts <- do.call(rbind,cmts)
  #long comments
  chrome$navigate(paste0(url,'reviews?sort=hotest'))
  lurl <- chrome$findElements('tag name','a')
  lurl <- unlist(geteleattr(lurl,attr='href'))
  lurl <- lurl[grep('#comment',lurl)]
  lcmts <- lapply(lurl,function(li){
    chrome$navigate(li)
    geteletext(chrome$findElement('id','link-report'))[[1]]
  })
  #output
  rlt <- list(url=url,info=info,intro=intro,shortcomment=cmts,longcomment=lcmts)
  rlt
}

model <- function(x){
  url <- get_movie_url(x)
  out <- get_movie_info(url$url)
  print(url)
  out
}

#########################
# Test
#########################

movies <- c('虎妈猫爸','芳华','妖猫传')
out <- lapply(movies,model)
