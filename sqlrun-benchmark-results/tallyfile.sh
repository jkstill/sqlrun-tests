#!/usr/bin/env bash

runSeconds=600

mode=$1
: ${mode:='sequential'}

echo mode: $mode

tallyDir=xaction-tally.${mode}

[ -d $tallyDir -a -x $tallyDir ] || { echo "error: cannot access $tallyDir"; exit 1; }

echo usercount,txtotal,txpersecond,responsetime

# sort -kn5 for the semi-random directory
# sort -kn4 for the sequential directory
for tallyFQN in $( ls -1 $tallyDir/xaction-600*.log  | sort -t- -k5n )
do
	#echo $tallyFQN
	fileName=$(basename $tallyFQN)
	userCount=$(echo $fileName | cut -f3 -d-)
	
	txTotal=$(awk '{ $t += $2 } END { print $t }' $tallyFQN)
	(( txPerSecond = txTotal / runSeconds ))
	responseTime=$(echo $runSeconds $txTotal | awk '{ r= $1 / $2 ; printf("%0.6f\n", r)  }' )

	echo $userCount,$txTotal,$txPerSecond,$responseTime
	
done

