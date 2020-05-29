#!/bin/bash

# Configure a couch as single cluster
#
# Usage:
# ./run-perf-test.sh http://admin:admin@localhost:5984

COUCHDB_URL="$1"

echo "cluster setup"
curl -XPOST --silent "$COUCHDB_URL/_cluster_setup" \
  -d '{"action":"enable_single_node","username":"admin","password":"admin","bind_address":"0.0.0.0","port":5984,"singlenode":true}' \
  -H 'Content-Type:application/json'
