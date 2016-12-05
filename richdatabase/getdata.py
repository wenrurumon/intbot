
import os
import sys
reload(sys)
sys.setdefaultencoding( "utf-8" ) 

#coding=utf-8
from selenium import webdriver
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.support.wait import WebDriverWait
import selenium.webdriver.support.ui as ui
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
import time
import datetime

starttime = datetime.datetime.now()

#username=u""
#password=u""
startpage=int(sys.argv[1])
pages=int(sys.argv[2])

browser = webdriver.Firefox()
#browser.get("http://112.65.173.210/")


browser.implicitly_wait(10000)
ActionChains(browser).key_down( Keys.F5).perform()
time.sleep(3)
browser.implicitly_wait(10000)

meteorjs=WebDriverWait(browser, 2000).until(
            EC.presence_of_element_located((By.CSS_SELECTOR, "head > script:nth-child(3)"))
        )
browser.implicitly_wait(10000)

#print meteorjs
#browser.add_cookie()

user=browser.find_element_by_css_selector(".username")
user.clear()
user.send_keys(username)

pwd=browser.find_element_by_css_selector(".userpwd")
pwd.clear()
pwd.send_keys(password)
checkbox=browser.find_element_by_css_selector(".login-reminder")
checkbox.click()
login=WebDriverWait(browser, 1000).until(
            EC.presence_of_element_located((By.CSS_SELECTOR, ".button"))
        )
browser.implicitly_wait(10000)


login.click()
browser.implicitly_wait(10000)
time.sleep(4)

ActionChains(browser).key_down( Keys.F5).perform()
browser.implicitly_wait(10000)
time.sleep(4)

ggyb=browser.find_element_by_css_selector(".init-open3 > ul:nth-child(2) > li:nth-child(4) > a:nth-child(1) > span:nth-child(1)")
#print ggyb.text[y]
browser.implicitly_wait(10000)
ggyb.click()
#print browser.get_cookies()

browser.find_element_by_css_selector("#size").clear()
browser.find_element_by_css_selector("#size").send_keys("100")
browser.implicitly_wait(10000)
time.sleep(4)
ggyb.click()
browser.find_element_by_css_selector("#index").clear()
browser.find_element_by_css_selector("#index").send_keys(startpage)
browser.implicitly_wait(10000)
time.sleep(4)
ggyb.click()


attr = browser.find_element_by_css_selector(".bg-info")
browser.implicitly_wait(10000)
#print attr.text
yanbaos = browser.find_element_by_css_selector("table.table:nth-child(2) > tbody:nth-child(2)")

print "###########################START from %d to %d###########################" % (startpage,startpage+pages-1)
print "setup finished", ((datetime.datetime.now()-starttime).seconds)

j = (startpage-1)*100+1
f = open("summary_%d_%d.txt"%(startpage,startpage+pages-1),"w+")
f2 = open("url_%d_%d.txt"%(startpage,startpage+pages-1),"w+")

for i in range(0,pages):

	browser.implicitly_wait(10000)
	time.sleep(4)

	for yb in yanbaos.find_elements_by_tag_name("tr"):
	    browser.implicitly_wait(10000)
	    #print yb.text
	    url_ele = yb.find_element_by_tag_name("a")
	    url = url_ele.get_attribute("href")
	    #print url
	    title = yb.find_elements_by_tag_name("td")[-1]
	    title = title.get_attribute("title")
	    nowtime = datetime.datetime.now()
		#print title
	    line = '%d - %s - %s - %s - %s\n' % (j,nowtime,url,title,yb.text)
	    line2 = '%s\n' % url
	#    print line
	    f.write(line)
	    f2.write(line2)
	    j = j+1

	browser.find_element_by_css_selector(".nextPage").click()
	print j-1, ((datetime.datetime.now()-starttime).seconds)

f.close()
f2.close()
browser.close()
print "finished", ((datetime.datetime.now()-starttime).seconds)
