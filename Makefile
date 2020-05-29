start:
	docker run --rm -p 5984:5984 --name couchdb -e COUCHDB_USER=admin -e COUCHDB_PASSWORD=admin couchdb:3.1

setup:
	./setup.sh http://admin:admin@localhost:5984

data.csv:
	./run-perf-test.sh http://admin:admin@localhost:5984 > data.csv

graph.png: data.csv
	gnuplot plot.gpi
