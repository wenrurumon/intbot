
rm(list=ls())
library(rvest)

########################################
#城市首页抓取

url <- 'http://www.dianping.com/search/category/2/10#breadCrumb'
web <- read_html(url)
cats <- web %>% html_nodes('#classfy a')
cats_name <- cats %>% html_text()
cats_url <- cats %>% html_attr('href')

########################################
#分类页面抓取

count.comment <- function(cat_url, slides=2){
	print(cat_url)
	urli.list <- paste0(cat_url,'o10p',1:slides)
	rlt <- lapply(urli.list,function(urli){
		webi <- read_html(urli)
		count.comment <- webi %>% html_nodes('.sear-highlight b') %>% html_text()	
		count.comment
	})
	as.numeric(unlist(rlt))
}

cats_count.comment <- lapply(cats_url[1:5],count.comment)
names(cats_count.comment) <- cats_name[1:5]
