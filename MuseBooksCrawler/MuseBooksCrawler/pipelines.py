# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: https://docs.scrapy.org/en/latest/topics/item-pipeline.html

import shutil

class MusebookscrawlerPipeline(object):
    def process_item(self, item, spider):
        print("index: %s" % item['index'])
        print("title: %s" % item['title'])
        print("content: \n %s" % item['content'])
        download_url_path = '/root/book/src/' + item['index'] + '.txt'
        print("writing to " + download_url_path)
        with open(download_url_path, 'w') as f:
            f.write(item['index'] + '\n')
            f.write(item['title'] + '\n')
            f.write(item['content'] + '\n')
        new_path = '/root/book/crawl_complete/' + item['index'] + '.txt'
        shutil.copyfile(download_url_path, new_path)
        return item
