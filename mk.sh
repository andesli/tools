#!/bin/bash

##########################
# author: andesli
# version: 0.1
# last modify: 2017-08-08
##########################

function log(){
    local msg="$@";
    local debug=true
    if [[ ${debug} == true ]];then
        echo "[$(date +"%Y-%m-%d %H:%M:%S")] ${msg}" |tee -a ${logFile}
    else
        echo "[$(date +"%Y-%m-%d %H:%M:%S")] ${msg}" >> ${logFile}
    fi
}

function logResult(){
    local msg="$@";
    local debug=true
    if [[ ${debug} == true ]];then
        echo "[$(date +"%Y-%m-%d %H:%M:%S")] ${msg}" |tee -a ${resultFile}
    else
        echo "[$(date +"%Y-%m-%d %H:%M:%S")] ${msg}" >> ${resultFile}
    fi
}

function usage(){
cat <<EOF
$0 -s SETID -v setid&setid -p server-type -m run-mode  -t type 
options:
	-s SETID 
	-v SETID&SETID
	-p server-type
	-m run-mode 
		TEST: 
		REAL
	-t type  
		query 
		set 
		clear
EOF
}


function init() {
    curPath=$(cd $(dirname $0) && pwd);
    logPath="${curPath}/log";
    confPath="${curPath}/conf"
    dataPath="${curPath}/data"

    local leftPath=${0%.*}
    prefix=${leftPath##*/}
    local _date=$(date +"%Y%d%m")
    logFile="${logPath}/${prefix}_${_date}_detail.log"
    resultFile="${logPath}/${prefix}_${_date}_result.log"


    if [ ! -d ${logPath} ];then
        mkdir -p ${logPath}
    fi
    if [ ! -d ${confPath} ];then
        mkdir -p ${confPath}
    fi
    if [ ! -d ${tmpPath} ];then
        mkdir -p ${tmpPath}
    fi
}

function initParams(){
		ARGS=$(getopt -o hs:v:p:m:t: -- "$@")
		if (( $? != 0 ));then
				usage	
			exit 1
		fi

		eval set -- "${ARGS}"
		echo "ARGS=$ARGS"
		while true ;do
				case "$1" in 
						-s)
						 opSet="$2"
						 shift
						 ;;

						-v)
						 flagSet="$2"
						 shift
						 ;;

						-p)
						 server="$2"
						 shift
						 ;;

						-m)
						 runMode="$2"
						 shift
						 ;;

						-t)
						 action="$2"
						 shift
						 ;;

						-h)
						 usage
						 exit
						 ;;

						--)
						  shift
						  break
						  ;;
				esac
		shift
		done
}

function  run(){
	echo "running..."
}



function main()
{
	init "$@" 
	initParams "$@"
	run
}

main "$@"

