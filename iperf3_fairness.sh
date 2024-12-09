#!/bin/bash
if [ $# -ne 1 ]; then
    echo "Usage: $0 <destination_IP>"
    exit 1
fi

DEST_IP=$1

# Start iperf3 client in the background
echo "Starting iperf3 process 1 client to $DEST_IP..."
iperf3 -c "$DEST_IP" -p 5201 -t 60 > "bbr_process_1.txt" &  # Run iperf3 for 60 seconds in the background
PID1=$!
echo "Started iperf3 process 1 with PID $PID1"

echo "Starting iperf3 process 2 client to $DEST_IP..."
iperf3 -c "$DEST_IP" -p 5202 -t 60 > "bbr_process_2.txt" &  # Run iperf3 for 60 seconds in the background
PID2=$!
echo "Started iperf3 process 2 with PID $PID2"
