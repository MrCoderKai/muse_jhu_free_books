#!/bin/bash

function rand(){
    min=$1
    max=$(($2-$min+1))
    num=$(date +%s%N)
    echo $(($num%$max+$min))
}

rnd=$(rand 1 10)
echo $rnd

file="/root/stat.sh"
size=`ls -l $file | awk '{print $5}'`
echo $size
if [ $size -gt 1000 ];then
	echo "bigger"
else
	echo "smaller"
fi
BASE=10
BASE=$(printf "%.0f" `echo "$BASE*1.2"|bc`)
echo $BASE
sleep ${BASE}s
echo "weakup"
