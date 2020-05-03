pip3 install xlrd scrapy
mkdir -p /root/book/src
mkdir -p /root/book/crawl_complete
mkdir -p /root/book/failed
mkdir -p /root/book/success
mkdir -p /root/book/downloading
mkdir -p /root/book/pdf
echo 60 > /root/book/book_sleep_high
echo 30 > /root/book/book_sleep_low
echo 20 > /root/book/chapter_sleep_high
echo 10 > /root/book/chapter_sleep_low
