# RealTimeScanFolder
Scan folder in real time and implement user defined rule. 
This script will help to scan and generate some output in real time
Some project generate huge amount of output file and we need to generate some report based on these files.
For example CDR files which is generate in telecom companies.

# AUTHOR FARIZ.

1. Download script and uncompress file.
2. Change predefined variable values according your environment. 
		# Ypu can keep. Properly need to run today's files.
	dateee=`date +%Y%m%d`
    dateee_filter=`date +%Y-%m-%d`
    dateee_old=`date +%Y%m%d --date="1 day ago"` # how much day ago need to remove to olders files. 
	   # change it, You can add more 
    declare -r prePaid=""
    declare -r posPaid=""
    declare -r dispatch1=""
    declare -r dispatch2=""
		# better no change
    declare -r curr=`pwd`
    declare -r CacheDir=$curr/Cache
    declare -r LogDir=$curr/Log
    declare -r PidLog=$curr/PID
    declare -r Config=$curr/Config
    
    FileNameOutput="FileReportOut_"   # output file name prefix
    SleepPeriod="3"       # how much time need wait for scan fresh files. 
    RemoveFileDayAgo=10   # by this you will define how much day ago files need to delete

3. Check main function. You can change scenario also.
	main function will check any process running on background or not based on ~/PID/*.pid files
	if not running then it will run defined function. else it will by pass.
	Need to combine temporary files. ( can be changed )
	Remove old day files.

4. change RuleEnginee function under report.sh script according your business rules. 
	
4. Add this script into crontab or other scheduler tool. 

