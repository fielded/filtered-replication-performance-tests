#!/bin/bash

# Run performance tests
# 
# Usage:
# ./run-perf-test.sh http://admin:admin@localhost:5984

COUCHDB_URL="$1"

TESTS_COUNT=50
BATCH_SIZE=10000
IDS_COUNT=20000

# format time output
TIMEFORMAT='%3E'


# payloads
ids=$(
  cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n $IDS_COUNT | xargs -I UUID echo '"UUID"'
)


doc_ids_payload=$(
  echo "$ids" | jq -s '{ doc_ids: . }'
)
# in_selector_payload=$(
#   echo "$ids" | jq -s '{ selector: { _id: { "$in": . } } }'
# )
gt_selector_payload='{"selector": { "_id": { "$gt": "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz" } }}'
regex_selector_payload='{"selector": { "_id": { "$regex": "customer:(xlmKxDZHhCQfOd1HfyIdHbJbKfENirby|BGZwRWRyLIZBanxSAI1AOiPXnB4Rbn7D|kwZGGmF7qt6TEhIJYaaE6L24fO0clKWK)" } }}'


# setup database 'perf'
curl -XDELETE --silent "$COUCHDB_URL/perf" > /dev/null
curl -XPUT --silent "$COUCHDB_URL/perf" > /dev/null


for (( i=1; i<=$TESTS_COUNT; i++ ))
do
  docs_count=$(($i * $BATCH_SIZE / 1000))
  
  # upload docs 
  cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n $BATCH_SIZE \
    | xargs -I UUID echo '{"_id":"UUID"}' \
    | jq -s '{ docs: . }' \
    | curl -XPOST --silent "$COUCHDB_URL/perf/_bulk_docs" -H 'Content-Type:application/json' -d @- \
    > /dev/null

  doc_ids_time=$(
    {
      time echo "$doc_ids_payload" | curl -XPOST --silent "$COUCHDB_URL/perf/_changes?filter=_doc_ids" -H 'Content-Type:application/json' -d @- > /dev/null;
    } 2>&1
  )
  # in_selector_time=$(
  #   {
  #     time echo "$in_selector_payload" | curl -XPOST --silent "$COUCHDB_URL/perf/_changes?filter=_selector" -H 'Content-Type:application/json' -d @- > /dev/null;
  #   } 2>&1
  # )
  gt_selector_time=$(
    {
      time echo "$gt_selector_payload" | curl -XPOST --silent "$COUCHDB_URL/perf/_changes?filter=_selector" -H 'Content-Type:application/json' -d @- > /dev/null;
    } 2>&1
  )
  regex_selector_time=$(
    {
      time echo "$regex_selector_payload" | curl -XPOST --silent "$COUCHDB_URL/perf/_changes?filter=_selector" -H 'Content-Type:application/json' -d @- > /dev/null;
    } 2>&1
  )

  # echo "$docs_count, $doc_ids_time, $in_selector_time, $gt_selector_time, $regex_selector_time"
  echo "$docs_count, $doc_ids_time, $gt_selector_time, $regex_selector_time"
done
