#!/usr/bin/env bash


userCount=0
userName=$(id -u -n)

chk4perl () {
	ps -flu${userName} | grep '[p]erl ./sqlrun.pl' >/dev/null
	echo $?
}

for pass in {0..20}
do
	(( userCount = 10 + ($pass * 10) ))
	./sqlrun.sh "$userCount" 600

	while :
	do
		if [ $(chk4perl) ]; then
			sleep 10
		else
			break
		fi
	done

done
	
