#!/bin/bash

# Build longport-mcp command arguments
ARGS=("--http" "--bind" "0.0.0.0:8000")

# Add readonly flag if enabled
if [ "${LONGPORT_READONLY}" = "true" ]; then
    ARGS+=("--readonly")
fi

# Log directory is fixed to /var/log/longport-mcp
ARGS+=("--log-dir" "/var/log/longport-mcp")

# Get today's log file name
LOG_FILE="/var/log/longport-mcp/longport-mcp.log.$(date +%Y-%m-%d)"

# Execute longport-mcp and use tail to follow the log file, outputting to stdout
longport-mcp "${ARGS[@]}" &
LONGPORT_PID=$!

# Wait for log file to be created
sleep 2

# Tail the log file to stdout, which will be captured by docker logs
tail -F "$LOG_FILE" 2>/dev/null &
TAIL_PID=$!

# Wait for the main process
wait $LONGPORT_PID
EXIT_CODE=$?

# Kill the tail process when longport-mcp exits
kill $TAIL_PID 2>/dev/null

exit $EXIT_CODE
