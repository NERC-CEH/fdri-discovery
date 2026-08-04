#!/bin/bash

ts=$(date -u +%Y-%m-%dT%H:%M:%S.%NZ)
if [ -n "$1" ]
then
    id=$1
else
    echo "No id provided."
    exit 1
fi
sed "s/{ts}/$ts/g" activity-end.ttl | sed "s/{id}/$id/g"
