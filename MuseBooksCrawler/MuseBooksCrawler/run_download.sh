#!/bin/bash

ps_out=`ps -ef | grep $1 | grep -v 'grep' | grep -v $0`
result=$(echo $ps_out | grep "$1")
if [[ "$result" != "" ]];then
    echo "Running"
else
    echo "Not Running"
    nohup sh /root/muse_jhu_free_books/MuseBooksCrawler/MuseBooksCrawler/download_muse_books.sh >> /root/download_muse.log 2>&1 &
fi
