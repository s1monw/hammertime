#!/bin/bash
# Note: This requires http://stedolan.github.com/jq/
# This tool fetches the _source from an elasticsearch
# index and writes it to stdout

E_BADARGS=85
INDEX_NAME=""
HOST_NAME="localhost"
PORT="9200"

function usage {
  echo "Usage: `basename $0` index_name [host_name]"
  if [ $# -gt 0 ]; then
    echo "Error: $1"
  fi
  exit $E_BADARGS
}

if [ $# -lt 1 ]; then
  usage
fi

INDEX_NAME=$1

if [ $# -gt 1 ]; then
  HOST_NAME=$2
fi

which jq > /dev/null 2>&1

if [ $? -ne 0 ]; then
  usage "You must install jq from http://stedolan.github.com/jq"
fi

SCROLL_ID=`curl -s -XGET ${HOST_NAME}:${PORT}'/'${INDEX_NAME}'/_search?search_type=scan&scroll=11m&size=250' -d '{"query" : {"match_all" : {} }}' | jq '._scroll_id' | sed s/\"//g`

if [ "${SCROLL_ID}" == "" -o "${SCROLL_ID}" == "null" ]; then
    usage "FAILED TO GET SCROLL ID"
fi

RESULT=`curl -s -XGET ${HOST_NAME}:${PORT}'/_search/scroll?scroll=10m' -d ${SCROLL_ID}`

while [[ `echo ${RESULT} | jq -c '.hits.hits | length'` -gt 0 ]] ; do
  #echo "Processed batch of " `echo ${RESULT} | jq -c '.hits.hits | length'`
  SCROLL_ID=`echo $RESULT | jq '._scroll_id' | sed s/\"//g`
  echo $RESULT | jq -c '.hits.hits[] | ._source + {_id}'
  RESULT=$(eval "curl -s -XGET ${HOST_NAME}:${PORT}'/_search/scroll?scroll=10m' -d ${SCROLL_ID}")
done
