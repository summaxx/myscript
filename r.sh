#!/bin/bash

T=1417

while :
do
	TM=$(date "+%H%M")
	if [ $T == $TM ]
	then
		reboot
	fi
	sleep 30
done
