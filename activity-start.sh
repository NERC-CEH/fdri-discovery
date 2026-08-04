#!/bin/bash

ts=$(date -u +%Y-%m-%dT%H:%M:%S.%NZ)
id=$(uuidgen)
if [ -n "$1" ]
then
    id=$1
fi
sed "s/{ts}/$ts/g" activity-start.ttl | sed "s/{id}/$id/g"
