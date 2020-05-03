#!/bin/bash

rm -rf /root/book/crawl_complete/*

for i in {10307..15000};do
	echo "Copying ${i}.txt"
	cp -f /root/book/src/${i}.txt /root/book/crawl_complete/
done
