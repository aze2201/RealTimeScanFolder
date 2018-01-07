#!/bin/bash


## RUN THIS SCRIPT PER 5 MIN WITH CRONTAB

dateee=`date +%Y%m%d`
dateee_filter=`date +%Y-%m-%d`
dateee_old=`date +%Y%m%d --date="1 day ago"`

declare -r dispatch1=""
declare -r dispatch2=""
declare -r curr=`pwd`
declare -r CacheDir=$curr/Cache
declare -r LogDir=$curr/Log
declare -r PidLog=$curr/PID
declare -r Config=$curr/Config

FileNameOutput="FileReportOut_"
SleepPeriod="3"
RemoveFileDayAgo=10

logRemove() {
	# this function need to clan old and dirty Logs.
	local DayAgo=$1
	find $LogDir -type f -name "*.log" -mtime +${DayAgo} -exec rm {} \;
}

LogCombine() {
	local prfx=$1
	if [ -f $LogDir/$prfx.$FileNameOutput_$dateee.log ] ; then
		cat $LogDir/$prfx.$FileNameOutput_$dateee.log >> $LogDir/$FileNameOutput_$dateee.log
		rm $LogDir/$prfx.$FileNameOutput_$dateee.log
	fi
}


ProcessStatus() {
	local prfx=$1
	if [ -f $PidLog/$prfx.pid ] ; then
		local pid=$(cat $PidLog/$prfx.pid)
		local len=$(ps -ef  | grep -v grep | grep $pid | wc -l)
		if [ $len -ge 1 ] ; then
			return 0
		else
			return 1
		fi
	else
		return 1
	fi
}

currList() {
	# list current file list to get new file list
	local Folder=$1
	local prfx=$2
	ls -ltr $Folder| awk '{print $8}' > $CacheDir/$prfx.currList.cache
}

scannedList() {
	# get already scanned file which is need to filter from currList
	local prfx=$1
	if [ ! -f $CacheDir/$prfx.scanned_file.cache ]
	then
		touch $CacheDir/$prfx.scanned_file.cache
	fi
}

NeedToScanList() {
	# NeedToScanList() = currList()-scannedList() => output file which is need scan only.
	local prfx=$1
	diff --changed-group-format='%>' --unchanged-group-format='' $CacheDir/$prfx.scanned_file.cache $CacheDir/$prfx.currList.cache | grep $dateee > $CacheDir/$prfx.NeedToScan.cache
	sed -i '/^\s*$/d' $CacheDir/$prfx.NeedToScan.cache  # this line will remove empty line from file.
}


RuleEnginee() {
	# this is core rule.
	echo "Still not ready. Please develop it"
}

ListenFolder() {
	local Folder=$1
	local prfx=$2
	cd $Folder
	while true; do
		result_file=$prfx.$FileNameOutput_$dateee.log   # need to write output to different file to avoid file LOCK conflicts. 
		currList $Folder $prfx
		scannedList $prfx
		NeedToScanList $prfx
		CheckNeedToScanFile=$(cat $CacheDir/$prfx.NeedToScan.cache |wc -l)
		if [ $CheckNeedToScanFile -ne 0 ] ; then
			cat $CacheDir/$prfx.NeedToScan.cache | grep  --include=\*.{dat,add} "$dateee" |while read FileNames ; do
				# this is core rule. Your Rule will run in here only for fresh files which is not scanned.
				RuleEnginee  >> $LogDir/$result_file
			done
			mv $CacheDir/$prfx.currList.cache $CacheDir/$prfx.scanned_file.cache    # current List already scanned. so rename it.
		fi
	sleep ${SleepPeriod}s                                                                   # if folder content changes less frequently , then can be increase this value. 
	done
}

main() {
	# this function need to call per 5-10 min by CRONTAB.
	ProcessStatus dis1
	if [ $? -ne 0 ]; then
		ListenFolder $dispatch1 dis1 &
		echo $! > $PidLog/dis1.pid
	fi
	ProcessStatus dis2
	if [ $? -ne 0 ]; then
		ListenFolder $dispatch2 dis2 &
		echo $! > $PidLog/dis2.pid
	fi
	# Combine LOGS if you need to output one file from multiple folders. 
	LogCombine dis1
	LogCombine dis2
	# if you need to remove old files.
	logRemove $RemoveFileDayAgo
}

main
