#! /bin/bash


BOOK_ROOT="/root/book/"


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
    curl -L $url -O $filePath
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
	echo 
    else
	# success
	successFilePath=$BOOK_ROOT"success/"$index".txt"
	if [ -e $successFilePath ];then
		echo $myline >> $successFilePath
	else
		echo $index >> $successFilePath
		echo $bookTitle >> $successFilePath
		echo $myline >> $successFilePath
	fi
	echo 
    fi
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
	    sleep 1s
	fi
    done < $FilePath
    wait # wait to finish
    rm $FilePath
}


for file in `ls $BOOK_ROOT"crawl_complete"`;do
    OLD_IFS=$IFS
    IFS="|"
    echo "Download "$file" ..."
    download_a_book "$file"
    sleep 1s
    IFS=$OLD_IFS
done
