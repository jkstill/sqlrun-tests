#!/usr/bin/env bash


userCount=0
userName=$(id -u -n)


#for pass in {0..20}
for pass in {1..30}
do
	(( userCount = 10 + ($pass * 10) ))

	#create/create.sh jkstill grok lestrade/pdb01

	./sqlrun.sh "$userCount" 600
	#./sqlrun.sh 2 5
	
	sleep 720

done
	
