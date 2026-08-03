#!/bin/bash

ts=$(date -u -I seconds | sed "s/+00:00$/Z/")
id=$(uuidgen)
if [ -n "$1" ]
then
    id=$1
fi
sed "s/{ts}/$ts/g" activity-start.ttl | sed "s/{id}/$id/g"
