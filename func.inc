#!/bin/bash


function f_GetData()
{
    set +x
    echo ${PAGE}|sed -r 's/(^.*'$1',)([^,]*)(.*)/\2/'
}

function f_ReadUsers()
{
    for s_USER in $s_PLAYERS;do
        ID=`sed -r 's/(.*id,)([^,]*)(.*)/\2/'<<<$s_USER`
        NICK=`sed -r 's/(.*name,)([^\)]*)(.*)/\2/'<<<$s_USER`
	USERNICK[${ID}]=${NICK}
	USERID[${NICK}]=${ID}
    done
}


function f_Results()
{
    set +x
    RESULTS=`sed -r 's/.*result.*\((.*)\),.*/\1/' <<<${PAGE}`
    IFS=, read -r -a array <<<${RESULTS}

    for index in "${!array[@]}"
    do
	if [ $((index%2)) == 0 ];then
	#nick=${array[index]}
	#ID=${USERID[$nick]}
	#USERRESULT[${ID}]=${array[index+1]}
	#echo "NICK $nick => ${USERRESULT[$ID]}"
	    echo "${array[index]} --> \$${array[index+1]}" >>${RESULTSFILE}
	fi
    done
}
