#/bin/bash

function fun(){
	var=$1
	echo $var
	sleep 10s
	echo $var'stop'
}


fun 1 &
fun 2 &
fun 3 &
echo $var'main1'
sleep 3s
echo $var'main2'
wait
