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

echo "configure session timeout"
curl -XPUT --silent "$COUCHDB_URL/_node/nonode@nohost/_config/couch_httpd_auth/timeout" -d '"86400"'

# TODO: this does not seem to work
echo "disable compaction"
curl -XPUT --silent "$COUCHDB_URL/_node/nonode@nohost/_config/compactions/_default" -d '"[{db_fragmentation, \"99%\"}, {from, \"02:00\"}, {to, \"06:00\"}, {strict_window, true}]"'
