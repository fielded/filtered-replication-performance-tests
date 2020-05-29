start:
	docker run --rm \
		-p 5984:5984 \
		-v $(CURDIR)/couch.ini:/opt/couchdb/etc/local.d/couch.ini:Z \
		-e COUCHDB_USER=admin \
		-e COUCHDB_PASSWORD=admin \
		--name couchdb \
		couchdb:3.1

setup:
	./setup.sh http://admin:admin@localhost:5984

data.csv:
	./run-perf-test.sh http://admin:admin@localhost:5984 > data.csv

graph.png: data.csv
	gnuplot plot.gpi
