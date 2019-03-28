#!/bin/sh

function log()
{
        local msg="$@";
		if [[ debug == "true" ]];then
       		 echo "[$(date +"%Y-%m-%d %H:%M:%S")] $msg" |tee -a  ${detailLog}
	    else	
       		 echo "[$(date +"%Y-%m-%d %H:%M:%S")] $msg" >>  ${detailLog}
		fi
}

function usage() {
cat <<EOF
$0 options:
		-i  no value
		-h  no value
		-f  have value
		-a  optional value
$0 ex:

EOF
}


function init()
{
		runMax=10
		tryMax=3
		debug=true

		workhome=$(cd $(dirname $0) && pwd);
		logPath="${workhome}/log";
		confPath="${workhome}/conf"
		aname=${0%.*}
		lname=${aname##*/}
		detailLog="${logPath}/${lname}_detail.log"

		if [ ! -d ${logPath} ];then
			mkdir -p ${logPath}
		fi
		if [ ! -d ${confPath} ];then
			mkdir -p ${confPath}
		fi


		ARGS=$(getopt -o ihf:a:: -- "$@")

		if (( $? != 0 ));then
			usage	
			exit
		fi

		eval set -- "${ARGS}"
		log $ARGS
		while true ;do
				case "$1" in 
						-i)
						  iFlag=true
						  log "-i is set"
						  ;;

						-f)
						  fvale="$2"
						  log "-f vale=${fvale}"
						  shift
						 ;;
						-a)
						   if [[ "$2" == "" ]];then 
								log "-a has no value"
						   else
								avale="$2"
								log "-a vale=${avale}"
						   fi
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

		if (( $#  != 3 ));then 
				log "$@"
				usage
				exit 1
		else
				param1="$1"
				param1="$2"
				param1="$3"
	    fi		

			log $param1 $param2 $param3
	logFile="${logPath}/${param1}_sum.log"

}

