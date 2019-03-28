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


function initIptables(){
	resultFile="${logPath}/${param1}_result.log"
	ipFile="${confPath}/ip.txt"
	remotecmd="iptables -L;"
	log "remotecmd=${remotecmd}"
}


function singleRun()
{
	local opIp=$1
	local opPwd=$2
	local logFile=$3
	local opCmd=$4

    	num=$(gossh  -h ${opIp} -p ${opPwd}  "${opCmd}" |egrep  -c 'error|ERROR')
    	gossh  -h ${opIp} -p ${opPwd}  "${opCmd}" 
	if (( ${num} == 0 ));then
	   #echo "ERROR" >>${logFile}
	   echo "OK" >>${logFile}
	else
	   echo "ERROR" >>${logFile} 
	fi

}

function multiRun()
{
	echo "params=$@"
	local initFunc=$1
	local cmd=$2
	local runMax=$3
	local tryMax=$4
	shift 6
	local params="$@"
	
	local loopFlag=1 
	local tryNums=1

	eval ${initFunc} "${params}"

	local configFile=${ipFile}
	local logFile=${logFile}
	local resultFile=${resultFile}

    while (( ${loopFlag} > 0 )) ;do
        >${logFile}
        runnings=0
        while read line ;do
	#	echo $line
            if (( ${runnings} < ${runMax} )) ;then
                ${cmd} ${line} ${logFile} "${remotecmd}" & 
                runnings=$((${runnings} + 1))
            else
                ${cmd} ${line} ${logFile} "${remotecmd}"  
                runnings=0
		wait
            fi
        done < ${configFile}
		wait
        num=$(cat ${configFile}|wc -l)
        if [ $(cat ${logFile}|grep "ERROR"|wc -l) -eq 0 -a $(grep "OK" ${logFile}|wc -l) -eq ${num} ];then
            echo "OK" > ${resultFile}
			loopFlag=0 
            break
		else
			if (( ${tryNums} >= ${tryMax} ));then
                while ((1));do
                    read -p "已经连续${tryMax}次失败，是否继续尝试吗？(Y/N);" tryrun
                    if [[ "X${tryrun}" == "XY" || "X${tryrun}" == "Xy" ]];then
                        tryNums=0
                        break
                    elif [[ "X${tryrun}" == "XN"  || "X${tryrun}" == "Xn" ]];then
						echo "ERROR" > ${resultFile}
						loopFlag=0 
                        break
                    fi
                done
			else
				tryNums=$(($tryNums+1))
				#echo "第${tryNums}次尝试"
			fi
        fi
    done
}

function main()
{
	init $@
	#multiRun initIptables singleRun ${ipFile} ${logFile} ${resultFile} ${runMax} ${tryMax} 
	multiRun initIptables singleRun ${runMax} ${tryMax} 
}

#main
main $@
