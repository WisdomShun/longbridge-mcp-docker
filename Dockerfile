FROM debian:bookworm-slim

# Install necessary dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    bash \
    curl \
    ca-certificates \
    netcat-openbsd && \
    rm -rf /var/lib/apt/lists/*

# Install longport-mcp tool
RUN ARCH="$(uname -m)" && \
    case "$ARCH" in \
        x86_64) BINARY_ARCH="x86_64-unknown-linux-gnu" ;; \
        aarch64) BINARY_ARCH="aarch64-unknown-linux-gnu" ;; \
        *) echo "Unsupported architecture: $ARCH" && exit 1 ;; \
    esac && \
    curl -sSL "https://github.com/longportapp/openapi/releases/latest/download/longport-mcp-${BINARY_ARCH}.tar.gz" -o /tmp/longport-mcp.tar.gz && \
    tar -xzf /tmp/longport-mcp.tar.gz -C /tmp && \
    mv /tmp/longport-mcp /usr/local/bin/longport-mcp && \
    chmod +x /usr/local/bin/longport-mcp && \
    rm -f /tmp/longport-mcp.tar.gz

# Create log directory
RUN mkdir -p /var/log/longport-mcp

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set working directory
WORKDIR /app

# Expose default port (for SSE mode)
EXPOSE 8000

# Use entrypoint script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
