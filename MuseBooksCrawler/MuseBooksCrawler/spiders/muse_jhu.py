# -*- coding: utf-8 -*-
import scrapy
import xlrd
import re
from MuseBooksCrawler.items import MusebookscrawlerItem
import os

class MuseJhuSpider(scrapy.Spider):
    name = 'muse_jhu'
    allowed_domains = ['muse.jhu.edu']
    download_url_txt_dir = "/root/book/src"
    download_url_txt_filename = ""
    URLS = []

    def start_requests(self):
        start_urls = ['http://muse.jhu.edu/book/42']
        book_list_dir = '/root/muse_free_books/MuseBooksCrawler/project_muse_free_covid_book.xlsx'
        title = []
        url = []
        title, url = self.read_book_title_url(book_list_dir)
        book_num = len(title)
#        for i in range(10):
#            self.log("title: %s, url: %s" % (title[i], url[i]))
#        for i in range(-10, 0):
#            self.log("title: %s, url: %s" % (title[i], url[i]))
        cnt = 0
        start_urls = url # update url
        self.URLS = url
        
################################# for failed items ##################
#        failed_idx = []
#        for root, dirs, files in os.walk("/root/book/failed_tmp/"):
#            for f in files:
#                f_tmps = f.split('.')
#                if f_tmps[1] == 'txt':
#                    failed_idx.append(int(f_tmps[0]))
#        failed_idx.sort()
#        self.log("Failed books: ")
#        print(failed_idx)
#
#        start_urls = []
#        for idx in failed_idx:
#            start_urls.append(url[idx - 1])
######################################################################
        for url in start_urls:
            self.log("Downloading from %s ... %d/%d" % (url, cnt, len(start_urls)))
            yield scrapy.Request(url=url, callback=self.parse)
            cnt = cnt + 1
            #if cnt >= 1:
            #    break;



    def parse(self, response):
        mbcItem = MusebookscrawlerItem()
        request_url = response.url
        mbcItem['index'] = str(self.URLS.index(request_url) + 1)
        title_tmp = response.xpath("//div[@id='book_banner_title']//h2//text()").extract()[0].split(':')[0]
        mbcItem['title'] = self.validateTitle(title_tmp.strip()).replace(' ', '-').replace('\t', '-').replace('\n', '-')
        #mbcItem['title'] = response.xpath("//div[@id='book_banner_title']//h2//text()").extract()[0].split(':')[0]
        self.log("book title: %s" % mbcItem['title'])
        content = ''
        for res in response.xpath("//div[@class='card_text']"):
            chapter = res.xpath(".//li[@class='title']//span//a//text()").extract()
            if (chapter is None or len(chapter) == 0):
                self.log("chapter is None or chapter length is 0")
                continue
            chapter = ''.join(chapter)
            chapter = chapter.replace('\n', ' ')
            download_url = res.xpath(".//ul[@id='action_btns']//li//@href").extract()[-2]
            download_url_full = "https://muse.jhu.edu" + download_url
            content = content + self.validateTitle(chapter.strip()).replace(' ', '-').replace('\t', '-').replace('\n', '-') \
                    + ' ' + download_url_full + '\n'
            self.log('chapter: %s, download_url = %s' % (chapter, download_url_full))
        mbcItem['content'] = content
        yield mbcItem # Will go to your pipeline



    def read_book_title_url(self, file_dir):
        xlsx_data = xlrd.open_workbook(file_dir)
        book_sheet = xlsx_data.sheet_by_name("MUSE Book Titles 2020-04-11")
        self.log('nrows: %d' % book_sheet.nrows)
        title = book_sheet.col_values(4, 1, book_sheet.nrows)
        url = book_sheet.col_values(3, 1, book_sheet.nrows)
        return title, url


    def validateTitle(self, title):
        rstr = r"[\/\\\:\*\?\"\<\>\|\']"  # '/ \ : * ? " < > | \''
        new_title = re.sub(rstr, "_", title) 
        return new_title
