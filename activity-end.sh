#!/bin/bash

ts=$(date -u -I seconds | sed "s/+00:00$/Z/")
if [ -n "$1" ]
then
    id=$1
else
    echo "No id provided."
    exit 1
fi
sed "s/{ts}/$ts/g" activity-end.ttl | sed "s/{id}/$id/g"
