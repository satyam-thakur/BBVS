#!/bin/bash

# CouchDB connection details
COUCHDB_URL="http://localhost:5984"
DB_NAME="mychannel1_voting6"
USERNAME="admin"
PASSWORD="adminpw"
# Function to get CouchDB statistics
get_couchdb_stats() {
curl -s -u $USERNAME:$PASSWORD "$COUCHDB_URL/_stats" | jq '.'
}

# Function to get system I/O stats
get_io_stats() {
iostat -x 1 2 | tail -n 2
}

# Function to get Fabric metrics (assuming Prometheus is set up)
get_fabric_metrics() {
curl -s http://localhost:9443/metrics | grep "ledger_transaction_count"
}

# Main loop
while true; do
echo "=== $(date) ==="

echo "CouchDB Stats:"
get_couchdb_stats

echo "I/O Stats:"
get_io_stats

echo "Fabric Metrics:"
get_fabric_metrics

echo ""
sleep 60  # Wait for 60 seconds before next measurement
done