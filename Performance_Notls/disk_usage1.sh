#!/bin/bash

# CouchDB Configuration
USERNAME="admin"
PASSWORD="adminpw"
COUCHDB_URL="http://localhost:5984"
DB_NAME="mychannel1_voting6"

# Fabric Prometheus Metrics URL
FABRIC_METRICS_URL="http://localhost:9443/metrics"

# Log file
LOG_FILE="fabric_metrics.log"

# Function to get CouchDB statistics
get_couchdb_stats() {
    curl -s -u $USERNAME:$PASSWORD "$COUCHDB_URL/_stats" | jq '{
        reads: .couchdb.httpd_request_methods.GET.value,
        writes: .couchdb.httpd_request_methods.PUT.value,
        disk_size: .couchdb.disk_size
    }'
}

# Function to get database-specific disk usage
get_db_disk_usage() {
    curl -s -u $USERNAME:$PASSWORD "$COUCHDB_URL/$DB_NAME" | jq '{
        disk_size: .sizes.active,
        data_size: .sizes.external
    }'
}

# Function to get system I/O statistics
get_io_stats() {
    echo "I/O Stats:"
    iostat -dx 1 2 | tail -n 5  # Disk read/write utilization
}

# Function to get CouchDB process-specific I/O usage
get_pid_io_stats() {
    echo "CouchDB Process I/O Stats:"
    pidstat -d 1 2 | grep "beam.smp"
}

# Function to get Fabric metrics (assuming Prometheus is set up)
get_fabric_metrics() {
    echo "Fabric Metrics:"
    curl -s $FABRIC_METRICS_URL | grep -E "ledger_transaction_count|ledger_blockchain_height"
}

# Continuous Monitoring Loop
while true; do
    echo "=== $(date) ===" | tee -a $LOG_FILE
    
    echo "CouchDB Stats:" | tee -a $LOG_FILE
    get_couchdb_stats | tee -a $LOG_FILE

    echo "Database Disk Usage:" | tee -a $LOG_FILE
    get_db_disk_usage | tee -a $LOG_FILE

    get_io_stats | tee -a $LOG_FILE
    get_pid_io_stats | tee -a $LOG_FILE

    get_fabric_metrics | tee -a $LOG_FILE

    echo "" | tee -a $LOG_FILE
    sleep 60  # Collect metrics every 60 seconds
done
