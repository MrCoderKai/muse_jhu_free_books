# -*- coding: utf-8 -*-
import scrapy


class JhuSpider(scrapy.Spider):
    name = 'jhu'
    allowed_domains = ['jhu.edu']
    start_urls = ['http://jhu.edu/']

    def parse(self, response):
        pass
