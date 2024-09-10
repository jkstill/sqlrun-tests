#!/usr/bin/env bash

scriptHome=$(dirname -- "$( readlink -f -- "$0"; )")
cd $scriptHome || { echo "cd $scriptHome failed"; exit 1; }

username=$1
password=$2
database=$3

echo exit | sqlplus $username/$password@$database @create.sql


