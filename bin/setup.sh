#!/bin/bash

PARENT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd ${PARENT}
echo "Downloading latest ElasticSearch Build"
curl -O https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-master.zip
unzip -d ${PARENT}/.. elasticsearch-master.zip 
ln -s ${PARENT}/../elasticsearch-0.90.0.Beta2-SNAPSHOT ${PARENT}/../elasticsearch
rm elasticsearch-master.zip

echo "Downloading latest stream2es binary"
curl -o ${PARENT}/stream2es download.elasticsearch.org/stream2es/stream2es; chmod +x ${PARENT}/stream2es
