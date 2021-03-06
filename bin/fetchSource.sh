#!/bin/bash
# Note: This requires http://stedolan.github.com/jq/
# This tool fetches the _source from an elasticsearch
# index and writes it to stdout

E_BADARGS=85

if [ ! -n "$1" ]
then
  echo "Usage: `basename $0` index_name"
  exit $E_BADARGS
fi
INDEX_NAME=$1
SCROLL_ID=`curl -s -XGET 'localhost:9200/'${INDEX_NAME}'/_search?search_type=scan&scroll=11m&size=250' -d '{"query" : {"match_all" : {} }}' | jq '._scroll_id' | sed s/\"//g`
RESULT=`curl -s -XGET 'localhost:9200/_search/scroll?scroll=10m' -d ${SCROLL_ID}`

while [[ `echo ${RESULT} | jq -c '.hits.hits | length'` -gt 0 ]] ; do
  #echo "Processed batch of " `echo ${RESULT} | jq -c '.hits.hits | length'`
  SCROLL_ID=`echo $RESULT | jq '._scroll_id' | sed s/\"//g`
  echo $RESULT | jq -c '.hits.hits[] | ._source + {_id}' 
  RESULT=$(eval "curl -s -XGET 'localhost:9200/_search/scroll?scroll=10m' -d ${SCROLL_ID}")
done
