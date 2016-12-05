
import os
import sys
reload(sys)
import time
import urllib2
import datetime
import re
sys.setdefaultencoding( "utf-8" ) 
#coding=utf-8

#log = open('getwebsite.log','w+')

def parse_test(pagesize,index):
	line = ('Parse pagesize = %s, index = %s, time = %s' % (pagesize,index,datetime.datetime.now()))
	print line
	url = 'http://www.jumeiglobal.com/ajax_new/getDealsByPage?type=new&pagesize=%s&index=%s&page=index&callback=global_load_callback'%(pagesize,index)
	response = urllib2.urlopen(url,timeout = 10)
	html = response.read().decode('unicode-escape')
	#html = response.read()
	return html

def getwebsite():
	def parse(pagesize,index):
		line = ('Parse pagesize = %s, index = %s, time = %s' % (pagesize,index,datetime.datetime.now()))
		#print line
		#log.write('%s\n'%line)
		url = 'http://www.jumeiglobal.com/ajax_new/getDealsByPage?type=new&pagesize=%s&index=%s&page=index&callback=global_load_callback'%(pagesize,index)
		response = urllib2.urlopen(url,timeout = 10)
		html = response.read().decode('unicode-escape')
		#html = html.split(',')	
		time.sleep(10)
		return html
	html1 = parse(10,0)
	html2 = parse(20,10)
	html3 = parse(20,30)
	html4 = parse(20,50)
	html5 = parse(20,70)
	html = [html1,html2,html3,html4,html5]
	html = ','.join(html)
	#html = parse(100,0)
	#html = html.split(',')
	return(html)
	#f = open('temp.txt','w+')
	#for i in html:
	#	f.write('%s\n'%i)

def parsewebsite():
	rcode = '''
	raw <- readLines('temp.txt')
	label <- c(product = 'pro_stitle', longname = 'medium_name', 
	           price = 'price_home', regprice = 'price_ref', vol = 'buyer_number',
	           expiretime = 'end_time_string', expire = 'pro_status"')
	files <- sapply(label,function(x){
	  x <- grep(x,raw,value = T)
	  sapply(x,function(x){gsub('\"','',strsplit(x,':')[[1]][2])})
	})
	now <- gsub('-','/',gsub(' CST','',Sys.time()))
	files <- cbind(now,files)
	files[,8] <- files[,8]=="2"
	write.table(files[,-7],paste('day',gsub('[^0-9]','',now),'.csv',sep=""),row.names=FALSE,sep='\t')
	print(paste('day',gsub('[^0-9]','',now),'.csv is generated',sep=""))
	'''
	rcode = open('rcode.r','w+').write(rcode)
	os.system('Rscript rcode.r')
	os.system('rm rcode.r temp.txt')

def parsewebsite2(html,now):
	f = open('day%s.txt'%(now.year*10000000000+now.month*100000000+now.day*1000000+now.hour*10000+now.minute*100+now.second),'w+')
	phtml = html.split(',')
	now = '%s/%s/%s %s:%s:%s'%(now.year,now.month,now.day,now.hour,now.minute,now.second)
	line = ('time\texpire_status\tproduct_name\tlong_desc\tprice\tregular_price\tvolume\n')
	#print line
	f.write(line)
	for i in phtml:
		if re.match(u'"pro_status"',str(i)):
			line = '%s\t%s'%(now,i.split(':')[1])
		if re.match(u'"pro_stitle"',str(i)): 
			line = '%s\t%s'%(line,i.split(':')[1])
		if re.match(u'"medium_name"',str(i)):
			line = '%s\t%s'%(line,i.split(':')[1])
		if re.match(u'"price_home"',str(i)):
			line = '%s\t%s'%(line,i.split(':')[1])
		if re.match(u'"price_ref"',str(i)):
			line = '%s\t%s'%(line,i.split(':')[1])
		if re.match(u'"buyer_number"',str(i)):
			line = '%s\t%s\n'%(line,i.split(':')[1])
			#print line
			f.write(line)

def wait(x):
	if x < 25:
		targethour = x
		now = datetime.datetime.now()
		if now == datetime.datetime(now.year,now.month,now.day,targethour,0,0,0):
			target = now
			waittime = 0
		elif now.hour > targethour:
			target = now + datetime.timedelta(days = 1)
			target = datetime.datetime(target.year,target.month,target.day,targethour,0,0,0)
			waittime = (target-now).seconds
		else:
			target = datetime.datetime(now.year,now.month,now.day,targethour,0,0,0)
			waittime = (target-now).seconds
	else:
		now = datetime.datetime.now()
		target = now+datetime.timedelta(seconds = 30)
		waittime = (target-now).seconds
	line = '%s %s %s' % (waittime, 'seconds to wait, next round download will start at', target)
	print line
	#log.write('%s\n'%line)
	time.sleep(waittime)

def waittilltarget(ihour,iminute):
	now = datetime.datetime.now()
	if now == datetime.datetime(now.year,now.month,now.day,ihour,iminute,0):
		target = datetime.datetime(now.year,now.month,now.day,ihour,iminute,0)
		waittime = 0
	elif now.hour<=ihour and now.minute<=iminute:
		target = datetime.datetime(now.year,now.month,now.day,ihour,iminute,0)
		waittime = (target-now).seconds
	else:
		target = now + datetime.timedelta(days = 1)
		target = datetime.datetime(target.year,target.month,target.day,ihour,iminute,0)
		waittime = (target-now).seconds
	line = '%s %s %s' % (waittime, 'seconds to wait, next round download will start at', target)
	print line
	time.sleep(waittime)

def test(times):
	j = 0
	while j <= times:
		wait(25)
		now = datetime.datetime.now()
		html = getwebsite()
		print 'Website got at', datetime.datetime.now()
		parsewebsite2(html,now)
		print 'Website parsed at', datetime.datetime.now()
		time.sleep(30)
		j = j+1
		print j

def mergeweek(now):
	enddate = now
	enddate_label = enddate.year*10000000000+enddate.month*100000000+enddate.day*1000000
	enddate = now+datetime.timedelta(days=1)
	enddate = enddate.year*10000000000+enddate.month*100000000+enddate.day*1000000
	startdate = now - datetime.timedelta(days=6)
	startdate = startdate.year*10000000000+startdate.month*100000000+startdate.day*1000000
	f = open('week%s-%s.txt'%(startdate/1000000,enddate_label/1000000),'w+')
	line = ('time\texpire_status\tproduct_name\tlong_desc\tprice\tregular_price\tvolume\n')
	f.write(line)
	files = os.listdir(os.getcwd())	
	files2 = []
	for i in files:
		if re.search('txt',i) and re.search('day',i):
			i = int(filter(lambda i:i.isdigit(),i))
			if i>=startdate and i <= enddate:
				files2.append('day%s.txt'%i)
	for i in files2:
		i = open(i,'r')
		j = 1
		for i2 in i.readlines():
			if j>1:
				f.write(i2)
			j = j+1
		i.close()
	f.close()

def mergeweek(now):
	enddate = now
	enddate_label = enddate.year*10000000000+enddate.month*100000000+enddate.day*1000000
	enddate = now+datetime.timedelta(days=1)
	enddate = enddate.year*10000000000+enddate.month*100000000+enddate.day*1000000
	startdate = now - datetime.timedelta(days=6)
	startdate = startdate.year*10000000000+startdate.month*100000000+startdate.day*1000000
	f = open('week%s-%s.txt'%(startdate/1000000,enddate_label/1000000),'w+')
	line = ('time\texpire_status\tproduct_name\tlong_desc\tprice\tregular_price\tvolume\n')
	f.write(line)
	files = os.listdir(os.getcwd())	
	files2 = []
	for i in files:
		if re.search('txt',i) and re.search('day',i):
			i = int(filter(lambda i:i.isdigit(),i))
			if i>=startdate and i <= enddate:
				files2.append('day%s.txt'%i)
	for i in files2:
		i = open(i,'r')
		j = 1
		for i2 in i.readlines():
			if j>1:
				f.write(i2)
			j = j+1
		i.close()
	f.close()

def mergemonth(now):
	enddate = now
	enddate_label = enddate.year*10000000000+enddate.month*100000000+enddate.day*1000000
	enddate = now+datetime.timedelta(days=1)
	enddate = enddate.year*10000000000+enddate.month*100000000+100000000-1
	startdate = now
	startdate = startdate.year*10000000000+startdate.month*100000000+1000000
	f = open('month%s-%s.txt'%(startdate/1000000,enddate_label/1000000),'w+')
	line = ('time\texpire_status\tproduct_name\tlong_desc\tprice\tregular_price\tvolume\n')
	f.write(line)
	files = os.listdir(os.getcwd())	
	files2 = []
	for i in files:
		if re.search('txt',i) and re.search('day',i):
			i = int(filter(lambda i:i.isdigit(),i))
			if i>=startdate and i <= enddate:
				files2.append('day%s.txt'%i)
	for i in files2:
		i = open(i,'r')
		j = 1
		for i2 in i.readlines():
			if j>1:
				f.write(i2)
			j = j+1
		i.close()
	f.close()

now = datetime.datetime.now()
html = getwebsite()
parsewebsite2(html,now)
print 'Warm up finished'
time.sleep(30)

while True:
	waittilltarget(23,55)
	now = datetime.datetime.now()
	html = getwebsite()
	print 'Website got at', datetime.datetime.now()
	parsewebsite2(html,now)
	print 'Website parsed at', datetime.datetime.now()
	time.sleep(30)
	if now.weekday() == 6:
		mergeweek(now)
	if now.month != (now+datetime.timedelta(days=1)).month:
		mergemonth(now)
	waittilltarget(10,10)
	now = datetime.datetime.now()
	html = getwebsite()
	print 'Website got at', datetime.datetime.now()
	parsewebsite2(html,now)
	print 'Website parsed at', datetime.datetime.now()
	time.sleep(30)
