#! /bin/bash


BOOK_ROOT="/root/book/"


function countLine(){
    return `awk 'END{print NR}' $1`
}


function download_a_chapter(){
    myline=$1
    index=$2
    bookTitle=$3
    OLD_IFS=$IFS
    IFS=" "
    array=($myline)
    IFS=$OLD_IFS
    #echo "myline: "$myline
    #echo "index: "$index
    #echo "bookTitle: "$bookTitle
    #for var in ${array[@]};do
    #    echo "var: "$var
    #done
    chapter=${array[0]}
    url=${array[1]}
    echo "Downloading chapter: "$chapter" from "$url
    filePath=$BOOK_ROOT"pdf/"$index"."$bookTitle"/"$chapter".pdf"
    if [ -e $filePath ];then
	    rm -rf $filePath
    fi
    wget $url -O $filePath
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
	    mkdir $saveDir
        elif [ -n "$myline" ];then
	    download_a_chapter "$myline" $index $bookTitle &
	fi
    done < $FilePath
    wait # wait to finish
    rm $FilePath
}

for file in `ls $BOOK_ROOT"crawl_complete"`;do
    echo "Download "$file" ..."
    download_a_book "$file"
done
