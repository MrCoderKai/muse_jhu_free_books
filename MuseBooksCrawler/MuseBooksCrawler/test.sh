#!/bin/bash

s="Cover	https://muse.jhu.edu/chapter/440/pdf"
OLD_IFS=$IFS
IFS="\t"
arr=$s
IFS=$OLD_IFS
for i in $arr;do
	echo $i
done


s="/root/book/src"
if [ -d "$s" ];then
	echo "$s exists"
else
	echo "$s does not exists"
fi
