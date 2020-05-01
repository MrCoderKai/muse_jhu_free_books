#! /bin/bash


BOOK_ROOT="/root/book/"


function rand(){
    min=$1
    max=$(($2-$min+1))
    num=$(date +%s%N)
    echo $(($num%$max+$min))
}


function countLine(){
    return `awk 'END{print NR}' $1`
}


function download_a_chapter(){
    myline=$1
    index=$2
    bookTitle=$3
    array=($myline)
    #echo "myline: "$myline
    #echo "index: "$index
    #echo "bookTitle: "$bookTitle
    #for var in ${array[@]};do
    #    echo "var: "$var
    #done
    chapter=${array[0]}
    #chapter=`expr substr "$chapter" 1 30`
    url=${array[1]}
    echo "\nDownloading chapter: "$chapter" from "$url
    filePath=$BOOK_ROOT"pdf/"$index"."$bookTitle"/"$chapter".pdf"
    if [ -e $filePath ];then
	    rm -rf $filePath
    fi
    #wget -c -t 10 $url -O $filePath
    download_continue_flag=0
    IP_BAN_SLEEP_BASE=1500
    while [ $download_continue_flag -eq 0 ];do
    	curl -A "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.0)" -L -o $filePath $url
    	#curl -L $url -o $filePath
	if [ $? -ne 0 ];then
		# fail
		failFilePath=$BOOK_ROOT"failed/"$index".txt"
		if [ -e $failFilePath ];then
			echo $myline >> $failFilePath
		else
			echo $index >> $failFilePath
			echo $bookTitle >> $failFilePath
			echo $myline >> $failFilePath
		fi
		download_continue_flag=1
	else
		# success
		download_size=`ls -l ${filePath} | awk '{print $5}'`
		if [ $download_size -gt 2500 ];then
			download_continue_flag=1
			successFilePath=$BOOK_ROOT"success/"$index".txt"
			if [ -e $successFilePath ];then
				echo $myline >> $successFilePath
			else
				echo $index >> $successFilePath
				echo $bookTitle >> $successFilePath
				echo $myline >> $successFilePath
			fi
		else
			download_continue_flag=0
			echo "Too many pdf download requests is encountered when download "$filePath
			IP_BAN_SLEEP_BASE=$(printf "%.0f" `echo "$IP_BAN_SLEEP_BASE*1.2"|bc`)
			echo "sleep "$IP_BAN_SLEEP_BASE" seconds ..."
			sleep ${IP_BAN_SLEEP_BASE}s
			echo "Time up, weakup. ($IP_BAN_SLEEP_BASE seconds.)"
		fi
    	fi
    done
}


function download_a_book(){
    filename=$1
    OriginalFilePath=$BOOK_ROOT"crawl_complete/"$filename
    FilePath=$BOOK_ROOT"downloading/"$filename
    mv $OriginalFilePath $FilePath
    lineCnt=0
    bookTitle=""
    index=""
    saveDir=""
    while read myline
    do
	let lineCnt=$lineCnt+1
	if [ $lineCnt -eq 1 ];then
	    index=$myline
	elif [ $lineCnt -eq 2 ];then
	    bookTitle=$myline
	    saveDir=$BOOK_ROOT"pdf/"$index"."$bookTitle
	    echo "saveDir: "$saveDir
	    if [ -d "$saveDir" ];then
		echo "$saveDir exists."
		rm -rf $saveDir
	    fi
	    mkdir $saveDir
        elif [ -n "$myline" ];then
	    download_a_chapter "$myline" $index $bookTitle &
	    chapter_sleep_sec=$(rand 20 60)
	    sleep ${chapter_sleep_sec}s
	fi
    done < $FilePath
    wait # wait to finish
    rm $FilePath
}


for file in `ls $BOOK_ROOT"crawl_complete"`;do
    stop_file="/root/stop"
    stopped_file="/root/stopped"
    if [ -e $stopped_file ];then
	    rm -rf $stopped_file
    fi
    if [ -e $stop_file ];then
	    touch $stopped_file
	    break
    fi
    OLD_IFS=$IFS
    IFS="|"
    echo "Download "$file" ..."
    download_a_book "$file"
    book_sleep_sec=$(rand 40 80)
    sleep ${book_sleep_sec}s
    IFS=$OLD_IFS
done
