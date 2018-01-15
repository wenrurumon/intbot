
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
  print('navigate url for movie')
  info <- strsplit(geteletext(chrome$findElement('id','info'))[[1]],'\n')
  intro <- geteletext(chrome$findElement('id','link-report'))[[1]]
  #short comments
  print('get short comment for movie')
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
  print('get long comment for movie')
  chrome$navigate(paste0(url,'reviews?sort=hotest'))
  lurl <- chrome$findElements('tag name','a')
  lurl <- unlist(geteleattr(lurl,attr='href'))
  lurl <- lurl[grep('#comment',lurl)]
  lurl <- gsub('#comments','',lurl)
  lcmts <- lapply(lurl,function(li){
    chrome$navigate(li)
    try(geteletext(chrome$findElement('id','link-report'))[[1]])
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

model2 <- function(x){try(model(x))}

#########################
# Test
#########################

movies <- unlist(strsplit(
'迷雾
寂静岭
孤儿怨
第六感
闪灵
妖猫传
芳华
大护法
鲛珠传
看不见的客人
喜剧之王
楚门的世界
一天
火星救援
天使爱美丽
朗读者
后会无期
了不起的盖茨比
岁月神偷
模仿游戏
唐山大地震
卡萨布兰卡
阳光小美女
催眠大师
比利林恩的中场战事
海边的曼彻斯特
无人知晓
请以你的名字呼唤我
辩护人
假如爱有天意
'
  ,'\n'
))
out <- lapply(movies,model)
