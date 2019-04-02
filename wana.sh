#!/bin/bash
########################################################
# Soubor:  wana                                        #
# Datum:   26.03.2019                                  #
# Autor:   Abramov Mikhail, xabram00@stud.fit.vutbr.cz #
# Projekt: IOS c. 1                                    #
########################################################
POSIXLY_CORRECT=yes

function arg_err {
	echo "error in argument "$1""
	exit 1 
}	

function listIP_f {
	awk '{print $1}' |
        sort -u
	exit 0
}	

function listHosts_f {
	awk '{print $1}'|
	while read row; do
	  if [[ ($(host $row) == *"NXDOMAIN"*) || ($(host $row) == *"SERVFAIL"*) ]]; then
	    echo "$row"
	  else
	    host $row
	  fi
	done|
	awk '{print $NF}'|
	sort -u 
	exit 0
}	

function listUri_f {
	awk -F ' ' '$7~/[/]/{print $7}'|
	sort -u 
	exit 0
}	

function histIp_f {
	awk '{print $1}'|
	sort |
	uniq -c | 
	sort -nr|
	awk '{{printf("%s",$2)};{printf(" (%s)",$1)};{printf(": ")};for (i = 0; i<$1 ; i++) {printf("#")};{printf("\n")};}'
	exit 0
}	

function histLoad_f {
	awk -F '[' '{print substr($2,0,14)}'| 
	sed -r 's/[/:]+/ /g'|
	while read row; do
	  date --date="$row" +"%Y-%m-%d %H:%M"
	done|
	sort -n | 
	uniq -c | 
	awk '{{printf("%s ",$2)};{printf("%s ",$3)};{printf("(%s)",$1)};{printf(": ")};for (i = 0; i<$1 ; i++) {printf("#")};{printf("\n")};}'
	exit 0
}	
	
URI_flag=0
IPADDR_flag=0
output=0
datetime_a_flag=0
datetime_b_flag=0

for param in "$@"; do
  if [ "$1" = "-a" ]; then
	shift
	if [[ "$1" =~ [0-9]{4}-[0-9]{2}-[0-9]{2}[\r\n\t\f\v]{0,1}[0-9]{0,2}:{0,1}[0-9]{0,2}:{0,1}[0-9]{0,2} ]]; then
		datetime_a=$(date -d "${1}" "+%s")
		datetime_a_flag=1
		shift
	else
		arg_err
	fi	
  elif [ "$1" = "-b" ]; then
	shift
	if [[ "$1" =~ [0-9]{4}-[0-9]{2}-[0-9]{2}[\r\n\t\f\v]{0,1}[0-9]{0,2}:{0,1}[0-9]{0,2}:{0,1}[0-9]{0,2} ]]; then
		datetime_b=$(date -d "${1}" "+%s")
		datetime_b_flag=1
		shift	
	else
		arg_err
	fi	
  elif [ "$1" = "-ip" ]; then
	shift
	if [[ "$1" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}|^[a-z0-9]{0,4}:{0,1}[a-z0-9]{0,4}:{0,1}[a-z0-9]{0,4}:{0,1}[a-z0-9]{0,4}:{0,1} ]]; then
		IPADDR='grep '$1''
		IPADDR_flag=1
	else
		arg_err
	fi
  shift
  elif [ "$1" = "-uri" ]; then
	shift
	if [[ $1 =~ .{1,} ]]
		then
		URI='grep '$1''
		URI_flag=1
	else
		arg_err
	fi
  shift
  else
    break
  fi
done

#outputs

for param in "$@"; do
  if [ "$1" = "list-ip" ]; then
    output="list-ip"  
    shift
  elif [ "$1" = "list-hosts" ]; then
    output="list-hosts"
    shift
  elif [ "$1" = "list-uri" ]; then
    output="list-uri"
    shift
  elif [ "$1" = "hist-ip" ]; then
    output="hist-ip"
    shift  
  elif [ "$1" = "hist-load" ]; then
    output="hist-load"
    shift
  else
    break
  fi
done
list=($(ls -d "$@"))
if [ $# -eq 0 ]; then
  echo -n "enter the logfile name: "
  read var
  list=($(ls -d $var))
fi  
for param in "${list[@]}"; do
  if [[ "$param" =~ .{0,30}gz$ ]]; then
    gunzip -c $param
  else
    cat $param
  fi 
done |
if [[ $IPADDR_flag == 1 ]]; then
   $IPADDR
else
   awk '{print $0}'
fi |
if [[ $URI_flag == 1 ]]; then
   $URI
else
   awk '{print $0}'
fi |
if [[ $datetime_a_flag == 1 ]]; then
  while read row; do
    if [ $datetime_a -lt $(date -d "$(date --date="$(echo $row|awk -F '[' '{print substr($2,0,20)}' |sed '0,/[:]/s/[:]/ /'| sed -r 's/[/]+/ /g')" +"%Y-%m-%d %H:%M:%S")" "+%s") ] ; then
      echo "$row"
    fi  
  done 
else
   awk '{print $0}'  
fi |
if [[ $datetime_b_flag = 1 ]]; then
  while read row; do
    if [ $datetime_b -gt $(date -d "$(date --date="$(echo $row|awk -F '[' '{print substr($2,0,20)}' |sed '0,/[:]/s/[:]/ /'| sed -r 's/[/]+/ /g')" +"%Y-%m-%d %H:%M:%S")" "+%s") ] ; then
      echo "$row"
    fi
  done 
else
   awk '{print $0}'  
fi |
if [[ $output = "list-ip" ]]; then
  listIP_f
elif [ $output = "list-hosts" ]; then
  listHosts_f
elif [ $output = "list-uri" ]; then
  listUri_f
elif [ $output = "hist-ip" ]; then
  histIp_f
elif [ $output = "hist-load" ]; then
  histLoad_f 
else 
  awk '{print $0}'
fi
