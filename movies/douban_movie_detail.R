
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
  subs_name <- unlist(geteletext(chrome$findElement('class','title-text')))
  subs <- subs[unlist(geteletext(subs))%in%subs_name]
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
  name <- geteletext(chrome$findElement('xpath','//*[@id="content"]/h1'))[[1]]
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
  rlt <- list(name=name,url=url,info=info,intro=intro,shortcomment=cmts,longcomment=lcmts)
  rlt
}

model <- function(x){
  url <- get_movie_url(x)
  out <- get_movie_info(url$url)
  print(out$name)
  out
}

model2 <- function(x){try(model(x))}

#########################
# Test
#########################
movies <- '迷雾
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
老男孩
百鸟朝凤
艋舺 
汉江怪物
触不到的恋人
雪国列车
晚秋
奇怪的她（韩版重返20岁）
阿飞正传
海上花
刺客聂隐娘
哪啊哪啊神去村
千机变
解救吾先生
我的少女时代
蓝色大门
推手
喜宴
看上去很美
牯岭街少年杀人事件
土拨鼠之日
敦刻尔克
愤怒的葡萄
雨中曲
黑天鹅
借东西的小人阿莉埃蒂
岁月的童话
怪兽电力公司
了不起的狐狸爸爸
萤火虫之墓
夏洛特的网
玛丽和马克思
菊次郎的夏天
大鱼
星运里的错
国王的演讲
捉鬼敢死队
被解救的姜戈
罗生门
X战警：逆转未来（系列）
加勒比海盗
让子弹飞
本杰明巴顿奇事
入殓师
沉默的羔羊
回到未来
弗里达
魔力麦克1
情书
美丽人生
十二怒汉
海上钢琴师
告白
神偷奶爸
千与千寻
无耻混蛋
大侦探福尔摩斯
钢铁侠
惊天魔盗团
战狼2
隐藏人物
致命魔术
教父
布达佩斯大饭店
罗曼蒂克消亡史
步履不停
天使爱美丽
饮食男女
新龙门客栈
归来
罗马假日
指环王1
霍比特人1
那些年，我们一起追的女孩
湄公河行动
爱在黎明破晓前
甜蜜蜜
志明救春娇
乘风破浪
万物生长
老炮儿
山河故人
花与爱丽丝
闪光少女
泰坦尼克号
辛德勒的名单
贫民窟的百万富翁
恋恋笔记本
狼少年
逃出绝命镇
金福南杀人事件始末
完美陌生人
重返20岁（韩国电影《奇怪的她》大陆版）
匆匆那年
未麻的部屋
攻壳机动队95
阿基拉
新世纪福音战士剧场版：Air/真心为你
星际牛仔-天国之扉
恶童
千年女优
'
movies <- unlist(strsplit(gsub('  ','',movies),'\n'))

rlt <- list()
for(i in 1:length(movies)){
  rlt[[i]] <- model2(movies[i])
  names(rlt)[i] <- rlt[[i]]$name
}
