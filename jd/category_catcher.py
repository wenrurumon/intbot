import urllib.parse
import urllib.request
import re
from html.parser import HTMLParser
from html.entities import name2codepoint
from urllib.parse   import quote
from urllib.request import urlopen
from collections import Counter

def rank(s):
    return sorted(range(len(s)), key=lambda k: s[k])

def which(l,v):
    rlt = -1
    for i in range(0,len(l)):
        if(l[i]==v):
            rlt = i
    return(rlt)

def gethtml(url):
    user_agent = 'Mozilla/5.0 (X11; Linux x86_64; rv:53.0) Gecko/20100101 Firefox/53.0'
    headers ={'User-Agent':user_agent}
    req = urllib.request.Request(url, headers=headers)
    response = urllib.request.urlopen(req)
    html = response.read().decode()
    return html

def jdcat(prod):
    url='http://search.jd.com/Search?keyword='+prod+'&enc=utf-8'
    html = gethtml(url);
    parser = MyHTMLParser()
    parser.feed(html)
    content = parser.getContent()
    pt = re.compile('<meta name="description"(.*?)/><script>',re.S)
    parser2 = MyHTMLParser()
    match = pt.search(html)
    if(match):
        parser2.feed(match.group(1))
    rlt = parser2.getContent()
    return(rlt)

def jdcat_inloop(html):
    parser = MyHTMLParser()
    parser.feed(html)
    content = parser.getContent()
    pt = re.compile('<meta name="description"(.*?)/><script>',re.S)
    parser2 = MyHTMLParser()
    match = pt.search(html)
    if(match):
        parser2.feed(match.group(1))
    rlt = parser2.getContent()
    return(rlt)

def jdcat_loop(prod,loopmax=3):
    loopi = 0
    url='http://search.jd.com/Search?keyword='+prod+'&enc=utf-8'
    html = gethtml(url);
    parser = MyHTMLParser()
    parser.feed(html)
    content = parser.getContent()
    pt = re.compile('<meta name="description"(.*?)/><script>',re.S)
    parser2 = MyHTMLParser()
    match = pt.search(html)
    if(match):
        parser2.feed(match.group(1))
    rlt = parser2.getContent()
    #keep tracking similar product
    while((len(rlt)==0)&(loopi<=loopmax)):
        loopi = loopi+1
        print('loop++')
        pt2 = re.compile('<font class="skcolor_ljg">(.*?)</font>')
        match2 = pt2.findall(html)
        if(len(match2)==0):
            return(rlt)
        match2_counter = Counter(match2)
        match2_set = list(set(match2))
        match2_count = []
        for seti in match2_set:
            match2_count.append(match2_counter[seti]/len(match2))
        match2_cumsum = sorted(match2_count,reverse=True)
        thres = 0
        if(match2_cumsum[0]>0.5):
            thres = 0
        else:
            for i in range(1,len(match2_cumsum)):
                thres = thres+1
                match2_cumsum[i] = match2_cumsum[i] + match2_cumsum[i-1]
                if(match2_cumsum[i]>0.5):
                    break
        thres = sorted(match2_count,reverse=True)[thres]
        prod = ''
        for i in range(0,len(match2_set)):
            if(match2_count[i]>=thres):
                prod = prod + match2_set[i]
        if(loopi==loopmax):
            prod = ''.join([i for i in prod if not i.isdigit()])
        prod = quote(prod)
        url='http://search.jd.com/Search?keyword='+prod+'&enc=utf-8'
        html = gethtml(url);
        rlt = jdcat_inloop(html)
    return(rlt)

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

#################################################

f = open('skulist')
sku = f.readlines()
for i in range(len(sku)):
    sku[i] = sku[i].replace('\n','')

f.close()

rlt = []
url = []
for i in range(0,len(sku)):
    skui = sku[i]
    urli = 'http://search.jd.com/Search?keyword='+skui+'&enc=utf-8'
    rlti = jdcat_loop(skui)
    print(i)
    print(urli)
    print(rlti)
    url.append(urli)
    rlt.append(rlti)

for i in range(0,len(rlt)):
    print(url[i])
    print(rlt[i])


##########################

prod = sku[0]

url='http://search.jd.com/Search?keyword='+prod+'&enc=utf-8'
html = gethtml(url);
parser = MyHTMLParser()
parser.feed(html)
content = parser.getContent()
pt = re.compile('<meta name="description"(.*?)/><script>',re.S)
parser2 = MyHTMLParser()
match = pt.search(html)
if(match):
    parser2.feed(match.group(1))

rlt = parser2.getContent()
#inploop
pt2 = re.compile('<font class="skcolor_ljg">(.*?)</font>')
match2 = pt2.findall(html)
match2_counter = Counter(match2)
match2_set = list(set(match2))
match2_count = []
for seti in match2_set:
    match2_count.append(match2_counter[seti]/len(match2))

match2_cumsum = sorted(match2_count,reverse=True)
thres = 0
if(match2_cumsum[0]>0.5):
    thres = 0
else:
    for i in range(1,len(match2_cumsum)):
        thres = thres+1
        match2_cumsum[i] = match2_cumsum[i] + match2_cumsum[i-1]
        if(match2_cumsum[i]>0.5):
            break

thres = sorted(match2_count,reverse=True)[thres]
prod = ''
for i in range(0,len(match2_set)):
    if(match2_count[i]>=thres):
        prod = prod + match2_set[i]

prod_bk = prod
prod = quote(prod)
url='http://search.jd.com/Search?keyword='+prod+'&enc=utf-8'
html = gethtml(url);
rlt = jdcat_inloop(html)

