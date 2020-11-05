#!/bin/bash

date

SCRIPT_DIR=`dirname "$(readlink -f "$0")"`
#exec 2>>"${SCRIPT_DIR}/${LOG_FILE}"
cd ${SCRIPT_DIR}


source ${SCRIPT_DIR}/conf.inc
source ${SCRIPT_DIR}/func.inc

for GAME in $GAMES; do
URL=https://www.18xx.games/game/${GAME}

USERFILEDB=$SCRIPT_DIR/games/${GAME}.lastuser.db
RESULTSFILE=$SCRIPT_DIR/games/${GAME}.results

if [ ! -f "${USERFILEDB}" ]; then
    echo 0 > ${USERFILEDB}
fi

LASTSEND=$(stat -c %Y ${USERFILEDB})
NOW=$(date +%s)
TIMEPASSED=$(($NOW-$LASTSEND))
echo Mineło $TIMEPASSED

if [ $TIMEPASSED -gt ${RESEND_TIME} ];then
    echo "0" > ${USERFILEDB}
fi
LASTUSER=$(cat ${USERFILEDB})


PAGE=$(curl -s -k ${URL}|tr -d '"'|tr -d ']'|tr -d '[')
s_PLAYERS=`curl -s -k {$URL}|tr -d '['|tr -d ']'|tr -d '"'|sed -r 's/(.*players,Opal.hash)(.*)(,max_players.*)/\2/'|sed 's/Opal\.hash//g'|sed 's/,(/ (/g'`
f_ReadUsers
TITLE=$(f_GetData title)
LINK=https://www.18xx.games$(f_GetData app_route)
DESC=$(f_GetData description)
ACTIVEID=$(f_GetData acting)
TURN=$(f_GetData turn)
ROUND=$(f_GetData round)
STATUS=$(f_GetData status)
RESULT=$(f_GetData result)

if [ "$STATUS" = "active" ]; then
    #ACTIVEID=4003
    if [ $LASTUSER -ne $ACTIVEID ];then
	if [ ${#USERHO[$ACTIVEID]} -gt 1 ]; then
	    MSG=$(echo -ne "${TITLE}, Aktywny użytkownik: ${USER[$ACTIVEID]} (${USERNICK[$ACTIVEID]}),  \nRunda: ${ROUND},  Tura: ${TURN}   |  Link do gry: ${LINK}")
	    #"
	    $SCRIPT_DIR/send_HO_msg2.py "${USERHO[$ACTIVEID]}" "${MSG}"
	    echo $ACTIVEID > $USERFILEDB
	    echo $(date) _ wiadomosc wysłana _ Aktywny użytkownik: ${USERNICK[$ACTIVEID]}
	fi
    fi
else
    if [ ! -f ${RESULTSFILE} ]; then
	f_Results
	while read LINE
	do
	    $SCRIPT_DIR/send_HO_msg2.py "${USERHO[$ACTIVEID]}" "${LINE}"
	done <${RESULTSFILE}
    fi
fi

done
