#!/bin/bash
###############################################################################
# This script simply looks for a pid file in the parent directory passed
# in as a cmd argument and passed the content of the file to the kill command
###############################################################################
E_BADARGS=85

if [ ! -n "$1" ]
then
  echo "Usage: `basename $0` nodename"
  exit $E_BADARGS
fi

PARENT="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. && pwd )"
kill `cat $PARENT/$1.pid`
echo "send kill command to node "$1
