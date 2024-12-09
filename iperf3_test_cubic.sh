#!/bin/bash
if [ $# -ne 3 ]; then
    echo "Usage: $0 <destination_IP> <output_file> <json_file>"
    exit 1
fi

DEST_IP=$1
OUTPUT_FILE=$2
JSON_FILE=$3

# Start iperf3 client in the background
echo "Starting iperf3 client to $DEST_IP..."
iperf3 -c "$DEST_IP" -t 60 -J > "$JSON_FILE"&  # Run iperf3 for 60 seconds in the background
IPERF_PID=$!

start_time=$(date +%s%3N)
while true; do
    # OUTPUT=$(ss -a -i dport == 5201 | grep -m 1 "cwnd" | awk '{for (i=1; i<=NF; i++) if ($i ~ /cwnd/) print $i}' | cut -d':' -f2)
    REPORT=$(ss -a -i dst "$DEST_IP" dport == 5201 | grep " ssthresh" )
    end_time=$(date +%s%3N)
    CWND=$(echo "$REPORT" | grep -m 1 "cwnd" | awk '{for (i=1; i<=NF; i++) if ($i ~ /cwnd/) print $i}' | cut -d':' -f2)
    SSTHRESH=$(echo "$REPORT" | grep -m 1 "ssthresh" | awk '{for (i=1; i<=NF; i++) if ($i ~ /ssthresh/) print $i}' | cut -d':' -f2 | head -n 1)
    elapsed_time=$((end_time - start_time))
    if [ -n "$CWND" ]; then
        echo "${elapsed_time} - $CWND - $SSTHRESH" >> "$OUTPUT_FILE"
    else
        # Optionally log when no connection is found
        # TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
        # echo "$TIMESTAMP - No connection found" >> "$OUTPUT_FILE"
        break
    fi
    sleep 0.05
done