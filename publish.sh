#!/bin/bash

set -e

QUEUE_URL=$(awk '$1==ENVIRON["GITHUB_REF_NAME"] {print $2}' branch.map)
if [ -z "$QUEUE_URL" ]
then
  echo "SQS not found for $GITHUB_REF_NAME"
  exit 1
fi

S3_DESTINATION_PREFIX=$(awk '$1==ENVIRON["GITHUB_REF_NAME"] {print $3}' branch.map)
if [ -z "$S3_DESTINATION_PREFIX" ]
then
  echo "S3 Destination not found for $GITHUB_REF_NAME"
  exit 1
fi

for file in build/data/*.ttl
do 
  # Upload data to s3
  S3_DESTINATION=$S3_DESTINATION_PREFIX/${file#"build/"}
  echo Uploading $file to $S3_DESTINATION
  aws s3 cp $file $S3_DESTINATION

  # Publish data to sqs queue
  BODY=$(printf '{"payload":"%s","action":"replace-graph","context":"http://fdri.ceh.ac.uk/graph/%s","content-type":"text/turtle"}' $S3_DESTINATION ${file#"build/"})
  echo "Sending $BODY to $QUEUE_URL"
  aws sqs send-message --message-deduplication-id=$S3_DESTINATION --message-group-id=data --queue-url=$QUEUE_URL --message-body="$BODY"
done

S3_DESTINATION=$S3_DESTINATION_PREFIX/fdri-metadata.ttl
echo Uploading ontology/owl/fdri-metadata.ttl to $S3_DESTINATION
aws s3 cp ontology/owl/fdri-metadata.ttl $S3_DESTINATION
BODY=$(printf '{"payload":"%s","action":"replace-graph","context":"http://fdri.ceh.ac.uk/graph/%s","content-type":"text/turtle"}' $S3_DESTINATION fdri-metadata.ttl)
echo "Sending $BODY to $QUEUE_URL"
aws sqs send-message --message-deduplication-id=$S3_DESTINATION --message-group-id=data --queue-url=$QUEUE_URL --message-body="$BODY"

S3_DESTINATION=$S3_DESTINATION_PREFIX/dependencies.su
echo Uploading sample_data/dependencies.su to $S3_DESTINATION
aws s3 cp sample_data/dependencies.su $S3_DESTINATION
BODY=$(printf '{"payload":"%s","action":"sparql-update","content-type":"application/sparql-update"}' $S3_DESTINATION)
echo "Sending $BODY to $QUEUE_URL"
aws sqs send-message --message-deduplication-id=$S3_DESTINATION --message-group-id=data --queue-url=$QUEUE_URL --message-body="$BODY"