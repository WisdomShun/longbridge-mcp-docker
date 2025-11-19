#!/bin/bash

# Build longport-mcp command arguments
ARGS=("--http" "--bind" "0.0.0.0:8000")

# Add readonly flag if enabled
if [ "${LONGPORT_READONLY}" = "true" ]; then
    ARGS+=("--readonly")
fi

# Log directory is fixed to /var/log/longport-mcp
ARGS+=("--log-dir" "/var/log/longport-mcp")

# Execute longport-mcp
exec longport-mcp "${ARGS[@]}"
