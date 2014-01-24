#!/bin/bash

###############################################################################
# This script starts up an elasticsearch node based on the first argument 
# supplied to this script. 
# The Node will look for other nodes with the same cluster name set to 
# the user name obtained from `whoami` to prevent name clashes between
# computers in the same unicast network. It will also use a shared data
# directory outside of the the elasticsearch install directory.
#
# This script will wait until the node has joint the cluster relying soley
# on the fact that at least one ES node will start on port 9200
# DON'T USE THIS FOR PRODUCTION PURPOSES
###############################################################################

E_BADARGS=85

if [ ! -n "$1" ]
then
  echo "Usage: `basename $0` nodename"
  exit $E_BADARGS
fi
CLUSTER=`eval whoami`
PARENT="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. && pwd )"
echo "Starting node "$1
echo "cmd: "$PARENT"/elasticsearch/bin/elasticsearch -d -Des.cluster.name="$CLUSTER" -Des.path.data="$PARENT"/data -Des.node.name="$1" -p "$PARENT"/"$1".pid"
$PARENT/elasticsearch/bin/elasticsearch -d -Des.cluster.name=$CLUSTER -Des.path.data=$PARENT/data -Des.node.name=$1 -p $PARENT/$1.pid

NODE_STATS=`curl -s -XGET 'http://localhost:9200/_nodes/'$1'/stats'`
while [[ $? -eq 7 ]]; do
  echo "No node listening on port 9200. Retry after for 2 Seconds"
  sleep 2
  NODE_STATS=`curl -s -XGET 'http://localhost:9200/_nodes/'$1'/stats'`
done
while [[ `echo $NODE_STATS | grep "\"name\"" | wc -l` -eq 0 ]]; do
  echo "Node "${1}" has not joined the cluster yet. Retry after for 2 Seconds"
  sleep 2
  NODE_STATS=`curl -s -XGET 'http://localhost:9200/_nodes/'$1'/stats'`
done 

echo "Node "${1}" joined the cluster"
