#!/bin/bash

WHO=$1
echo "clean_cluster) WHO $WHO"
IFS=,
ary=($WHO)

numLeave=${#ary[@]}
echo "clean_cluster) num nodes [$numLeave]"

for key in "${!ary[@]}"; do
	node=${ary[$key]}
	num=$key
	IP_Node=$(ssh pi@$node 'ip -4 route get 8.8.8.8'|awk {'print $7'} | tr -d '\n')
	echo "clean_cluster) Num [$num] Node[$node] IP[$IP_Node]" 
        ssh pi@$node "/home/pi/adhoc-cloud/raspi/cleanup-etcd-rpi.sh 1"
done
