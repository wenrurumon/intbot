import scrapy
import json

class WinShangMall(scrapy.Spider):
    name = 'mall'
    max_page = 1947
    handle_httpstatus_list = [302]

    def start_requests(self):
        url_temp = 'http://bizsearch.winshang.com/xiangmu/s0-c0-t0-k0-x0-d0-z1-n0-m0-l0-q0-b0-y0-pn{page}.html'
        for p in range(1, self.max_page + 1):
            yield scrapy.Request(url_temp.format(page=p))

    def parse(self, response):
        print(response)
        links = response.xpath("//h2[@class='l-name']/a/@href").extract()
        for link in links:
            yield scrapy.Request(link, callback=self.extract_main)

    def extract_main(self, response):
        print(response)
        basic_info = {
            '商场名称': response.xpath("//h1[@class='d-brand-tit']/text()").extract_first(),
            '项目状态': response.xpath("//ul[@class='d-inf-list clearfix']//p[text()='项目状态']/preceding-sibling::h2/text()").extract_first(),
            '招商状态': response.xpath("//ul[@class='d-inf-list clearfix']//p[text()='招商状态']/preceding-sibling::h2/text()").extract_first(),
            '项目类型': response.xpath("//ul[@class='d-inf-status']//span[text()='项目类型']/following-sibling::span/text()").extract_first(),
            '开业时间': response.xpath("//ul[@class='d-inf-status']//span[text()='开业时间']/following-sibling::span/text()").extract_first(),
            '商业面积': response.xpath("//ul[@class='d-inf-status']//span[text()='商业面积']/following-sibling::span/text()").extract_first(),
            '商业楼层': response.xpath("//ul[@class='d-inf-status']//span[text()='商业楼层']/following-sibling::span/text()").extract_first(),
            '连锁项目': response.xpath("//ul[@class='d-inf-status']//span[text()='连锁项目']/following-sibling::span/text()").extract_first(),
            '室内地图': response.xpath("//ul[@class='d-inf-status']//span[text()='室内地图']/following-sibling::span/text()").extract_first(),
            '所属商圈': response.xpath("//ul[@class='d-inf-status']//span[text()='所属商圈']/following-sibling::span/text()").extract_first(),
            '所在城市': response.xpath("//ul[@class='d-inf-status']//span[text()='所在城市']/following-sibling::span/text()").extract_first(),
            '项目地址': response.xpath("//ul[@class='d-inf-status']//span[text()='项目地址']/following-sibling::span/text()").extract_first(),
            '图片': response.xpath("//div[@class='carousel carousel-navigation']//img/@src").re('(\S*)\?mod'),
            '项目简介': response.xpath("//h3[text()='项目简介']/following-sibling::div/p/text()").extract(),
            '硬件设施': response.xpath("//h3[text()='硬件设施']/following-sibling::div/p/text()").extract(),
            '开发商': response.xpath("//span[text()='开发商：']/following-sibling::span/text()").extract_first(),
            '上市企业': response.xpath("//span[text()='上市企业：']/following-sibling::span/text()").extract_first(),
            '开发商简介': response.xpath("//h3[text()='开发商简介']/following-sibling::div/p/text()").extract()
        }

        url_temp = 'http://biz.winshang.com/bizhtm/html/hand/projectAjax.ashx?action=maininfoget&id={id}&type={type}&cityID={cityId}&_=1501743263197'
        type = int(response.xpath('//script/text()').re(r"var type = (\d*)")[0])
        id = int(response.xpath('//script/text()').re(r"var id = '(\d*)'")[0])
        cityId = int(response.xpath('//script/text()').re(r"var cityID = '(\d*)'")[0])

        basic_info['mid'] = id

        yield scrapy.Request(url_temp.format(type=type, id=id, cityId=cityId), meta={'basic_info': basic_info}, callback=self.extract_all)

    def extract_all(self, response):
        basic_info = response.meta['basic_info']
        if response.status == 200:
            response = json.loads(str(response.body, encoding='utf-8'))
            del response['caiguanzhu']
            del response['islink']
            del response['zhaozuinfos']
            response['basic_info'] = basic_info
            yield response
            print(response)
        else:
            item = {'basic_info': basic_info}
            yield item
            print(response)
