#coding=utf-8
from selenium import webdriver
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.support.wait import WebDriverWait
import selenium.webdriver.support.ui as ui
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
import time
#username=u""
#password=u""

browser = webdriver.Firefox()

browser.get("http://112.65.173.210/")


browser.implicitly_wait(10000)
ActionChains(browser).key_down( Keys.F5).perform()
time.sleep(3)
browser.implicitly_wait(10000)

meteorjs=WebDriverWait(browser, 2000).until(
            EC.presence_of_element_located((By.CSS_SELECTOR, "head > script:nth-child(3)"))
        )
browser.implicitly_wait(10000)

print meteorjs
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
ggyb=browser.find_element_by_css_selector(".init-open3 > ul:nth-child(2) > li:nth-child(3) > a:nth-child(1)")
print ggyb.text
browser.implicitly_wait(10000)
ggyb.click()
print browser.get_cookies()


attr = browser.find_element_by_css_selector(".bg-info")
browser.implicitly_wait(10000)
print attr.text
yanbaos = browser.find_element_by_css_selector("table.table:nth-child(2) > tbody:nth-child(2)")
browser.implicitly_wait(10000)

for yb in yanbaos.find_elements_by_tag_name("tr"):
    browser.implicitly_wait(10000)
    print yb.text
