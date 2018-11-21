#!/bin/bash

case $1 in
"master")

   	echo "setup"
	#### MEM ISSUE docker run --rm --name adhoc-cloud-master -e HEAP_NEWSIZE=1M -e MAX_HEAP_SIZE=64M -d adhocc:latest
	docker run --rm --name adhoc-cloud-master -e HEAP_NEWSIZE=1M -e MAX_HEAP_SIZE=64M -e JVM_OPTS="-Xms64M -Xmx128M" -d adhocc:latest
	#docker run -m 320M --rm --name adhoc-cloud-master -e HEAP_NEWSIZE=1M -e MAX_HEAP_SIZE=64M -d adhocc:latest
	#docker run --rm --name adhoc-cloud-master -d adhocc:latest
	master_ip=`docker inspect --format='{{ .NetworkSettings.IPAddress }}' adhoc-cloud-master`
	echo "master IP is [" $master_ip "]"
        docker exec -e "WHOAMI=$master_ip" -i -t adhoc-cloud-master sh -c 'exec /usr/src/master.sh' 
        ;;

"nodes") 
	data_ini=`date +%s`
	fileName="data/data-addNodes-$data_ini-$2.dat"
	echo -e "num \t Acumtime \t TimeIns">>$fileName
	echo "$data_ini vols $2 fills"

	for ((i=1; i<=$2; i++))
	do
    		echo $i
	        data_iniIns=`date +%s`
		# nodeName="adhoc-cloud-node$i"
		# Determine node name
		alreadyexist="x"
		j=1
		while [ "$alreadyexist" != "" ];
		do
			nodeName="adhoc-cloud-node$j"
			alreadyexist=`docker ps | grep $nodeName`
			j=`expr $j + 1`
		done

		echo "nodeName $nodeName"
		#docker run --rm --name $nodeName -d -e HEAP_NEWSIZE=1M -e MAX_HEAP_SIZE=64M -e CASSANDRA_SEEDS="$(docker inspect --format='{{ .NetworkSettings.IPAddress }}' adhoc-cloud-master)"  adhocc:latest
		docker run  --rm --name $nodeName -d -e HEAP_NEWSIZE=1M -e MAX_HEAP_SIZE=64M -e CASSANDRA_SEEDS="$(docker inspect --format='{{ .NetworkSettings.IPAddress }}' adhoc-cloud-master)"  adhocc:latest
		#docker run -m 320M --rm --name $nodeName -d -e HEAP_NEWSIZE=1M -e MAX_HEAP_SIZE=64M -e CASSANDRA_SEEDS="$(docker inspect --format='{{ .NetworkSettings.IPAddress }}' adhoc-cloud-master)"  adhocc:latest
                nodeIP=`docker inspect --format='{{ .NetworkSettings.IPAddress }}' $nodeName`
                
	        ### solament arranco node	
		docker exec -e "WHOAMI=$nodeIP" -e "AUTO=true" -i -t $nodeName sh -c 'exec /usr/src/node.sh' 
		### faig insert a node
		#docker exec -e "WHOAMI=$nodeIP" -i -t $nodeName sh -c 'exec /usr/src/register.sh' 
	        
                #num=`docker exec -i -t $nodeName  sh -c 'nodetool status'| grep ^UN | wc -l`

                data_end=`date +%s`
                ELAPSED_TIME=`expr $data_end - $data_ini`
                ELAPSED_TIME_INS=`expr $data_end - $data_iniIns`
                echo -e "$i \t $ELAPSED_TIME \t $ELAPSED_TIME_INS">>$fileName
		
		## Using autobootstrap false to start nodes. Manual launch of sync to keep consistency
		#echo "Lauch cluster data sync after creation"
		#docker exec -i -t $nodeName sh -c 'nodetool bootstrap resume' 
		
		#echo "Num $num t $ELAPSED_TIME"
                #docker run -it -e "WHOAMI=$nodeIP" --link "$nodeName" --rm master-node:latest sh -c 'exec /usr/src/node.sh' 
	done

	data_end=`date +%s`
	ELAPSED_TIME=`expr $data_end - $data_ini`
	echo -e "TOTAL$2 \t $ELAPSED_TIME">>$fileName
		
	###echo "Before leaving. Sync all data..."
	###for ((i=0;i<$2;i++))
        ###do
	###	#$numNode=`eval($i+1)`
	###	numNode=`expr $i + 1`
	###	nodeName="adhoc-cloud-node$numNode"
	###	echo "Sync $nodeName..."
	###	docker exec -i -t $nodeName sh -c 'nodetool rebuild' 
        ###done
	###docker exec -i -t adhoc-cloud-master sh -c 'nodetool rebuild' 
	###echo "END Before leaving. Sync all data..."

	echo "bye"
	;;
*)
	echo "k ase?"
#if [ $1 == "setup" ]
#then
#   	echo "setup"
#	docker run --name adhoc-cloud-master -d master-node:latest
#	master_ip=`docker inspect --format='{{ .NetworkSettings.IPAddress }}' adhoc-cloud-master`
#	echo "master IP is [" $master_ip "]"
#        docker run -it -e "WHOAMI=$master_ip" --link adhoc-cloud-master --rm master-node:latest sh -c 'exec /usr/src/master.sh register' 
#	
#	echo "vols $2 fills"
#	for ((i=1; i<=$2; i++))
#	do
#    		echo $i
#		nodeName="adhoc-cloud-node$i"
#		echo "nodeName $nodeName"
#               #docker run --name node_fill  -d -e CASSANDRA_SEEDS="$(docker inspect --format='{{ .NetworkSettings.IPAddress }}' adhoc-cloud-master)"  master-node:latest
#                #docker run --name $nodeName -d -e CASSANDRA_SEEDS="$(docker inspect --format='{{ .NetworkSettings.IPAddress }}' adhoc-cloud-master)"  master-node:latest
#                echo `docker run --name $nodeName -d -e CASSANDRA_SEEDS="$(docker inspect --format='{{ .NetworkSettings.IPAddress }}' adhoc-cloud-master)"  master-node:latest`
#                #docker run --name adhoc-cloud-node$i -e "CASSANDRA_SEEDS=$master_ip" -d master-node:latest
#                echo `docker inspect --format='{{ .NetworkSettings.IPAddress }}' $nodeName`
#
#	done
#	
#	echo "bye"
#else
#	if  [ $1 == "clean" ]
#	then
#		echo "clean"
#		docker stop adhoc-cloud-master
#                docker rm adhoc-cloud-master
#	else
#   		echo "k ase?"
#	fi
#fi
;;
esac
