import urllib.parse
import urllib.request
import re
from html.parser import HTMLParser
from html.entities import name2codepoint
 
urls= ['https://omim.org/clinicalSynopsis/143100?highlight=huntington%20disease',
'http://search.jd.com/Search?keyword=meizu+7&enc=utf-8'];

def gethtml(url):
    user_agent = 'Mozilla/5.0 (X11; Linux x86_64; rv:53.0) Gecko/20100101 Firefox/53.0'
    headers ={'User-Agent':user_agent}
    req = urllib.request.Request(url, headers=headers)
    response = urllib.request.urlopen(req)
    html = response.read().decode()
    return html

# html 是整个页面的字符串，可以用各种方式解析

class MyHTMLParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self._content = ''
    def handle_starttag(self, tag, attrs):
        for attr in attrs:
            if(attr[1] == 'inheritance'):
                #print('>>>>>>')
                self._content += '>>>>>>\n'
                break
            if(attr[1] == 'collapseEditHistory'):
                #print('>>>>>>')
                self._content += '>>>>>>\n'
                break
    def handle_data(self, data):
        #data = data.strip()
        if(data.strip()):
            self._content += data+'\n'
    def getContent(self):
        return self._content


################################################################################

html = gethtml(urls[0]);
parser = MyHTMLParser()

# 你可以看看content长什么样 --！
parser.feed(html)
content = parser.getContent().split('>>>>>>')[1]
p = re.compile('\\[.*?\\]', re.S)
body = ''.join(p.split(content))

# 解析标题
pt = re.compile('<h3>(.*?)</h3>',re.S)
parser2 = MyHTMLParser()
match = pt.search(html)
if(match):
    parser2.feed(match.group(1))

title = ' '.join(parser2.getContent().split('\n'))

print(title)
print(body)

################################################################################

html = gethtml(urls[1]);
parser = MyHTMLParser()

parser.feed(html)
content = parser.getContent()

pt = re.compile('<ul class="J_valueList v-fixed">(.*?)</ul>',re.S)
parser2 = MyHTMLParser()
match = pt.search(html)
if(match):
    parser2.feed(match.group(1))

title = ' '.join(parser2.getContent().split('\n'))
title
