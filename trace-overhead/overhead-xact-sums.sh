#!/usr/bin/env bash

for rcfile in trc-ovrhd/* 
do
	awk '{ x+=$2 }END{printf("%30s %10d\n", $1 , x)}'  $rcfile
done

