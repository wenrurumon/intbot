import urllib2
from selenium import webdriver
import re
import sys

def getwebsite(url,filename):
	f = open(filename,'w+')
	#url = 'http://cn163.net/archives/8469/'
	browser = webdriver.Firefox()
	browser.get(url)
	content = browser.find_element_by_css_selector('.entry_box_s')
	urls = content.find_elements_by_tag_name('a')
	for i in urls:
		if i.get_attribute('href'):
			if re.search('ed2k',i.get_attribute('href')):
				f.write('%s\n'%i.get_attribute('href'))
	f.close()
	browser.close()

url = sys.argv[1]
filename = sys.argv[2]
getwebsite(url,filename)