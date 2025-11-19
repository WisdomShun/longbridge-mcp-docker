# LongportMCPDocker

[![Docker Build and Test](https://github.com/WisdomShun/LongportMCPDocker/actions/workflows/docker-build-test.yml/badge.svg)](https://github.com/WisdomShun/LongportMCPDocker/actions/workflows/docker-build-test.yml)
[![Docker](https://img.shields.io/badge/docker-ready-blue)](https://www.docker.com/)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

English | [简体中文](README_zh.md)

A Docker wrapper for the Longbridge MCP (Model Context Protocol) server, providing easy deployment and management of the Longport API service.

## Overview

This project packages the `longport-mcp` server in a Docker container, making it simple to deploy and run the Longport API service with proper configuration management, logging, and health checks.

## Features

- 🐳 **Docker-based deployment** - Easy setup with Docker Compose
- 🔒 **Secure configuration** - Environment variable-based credential management
- 📊 **Persistent logging** - Logs are stored in a mounted volume
- 💚 **Health monitoring** - Built-in health checks for service reliability
- 🔄 **Auto-restart** - Automatic container restart on failure
- 🏗️ **Multi-architecture support** - Supports both x86_64 and aarch64 (ARM64)

## Prerequisites

- Docker Engine (20.10.0 or later)
- Docker Compose (1.29.0 or later)
- Longport API credentials (APP_KEY, APP_SECRET, ACCESS_TOKEN)

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/WisdomShun/LongportMCPDocker.git
cd LongportMCPDocker
```

### 2. Configure Environment Variables

Create a `.env` file in the project root:

```bash
# Longport API Credentials (Required)
LONGPORT_APP_KEY=your_app_key_here
LONGPORT_APP_SECRET=your_app_secret_here
LONGPORT_ACCESS_TOKEN=your_access_token_here

# Server Configuration (Optional)
SERVER_PORT=8000
LONGPORT_READONLY=true
```

### 3. Build and Start the Service

```bash
# Build the Docker image
docker-compose build

# Start the service
docker-compose up -d
```

### 4. Verify the Service

```bash
# Check service status
docker-compose ps

# View logs
docker-compose logs -f longport-mcp

# Check health status
docker-compose exec longport-mcp nc -z localhost 8000 && echo "Service is healthy"
```

## Configuration

### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `LONGPORT_APP_KEY` | Yes | - | Your Longport application key |
| `LONGPORT_APP_SECRET` | Yes | - | Your Longport application secret |
| `LONGPORT_ACCESS_TOKEN` | Yes | - | Your Longport access token |
| `LONGPORT_READONLY` | No | `true` | Enable read-only mode for safety |
| `SERVER_PORT` | No | `8000` | Port to expose the service on the host |

### Read-Only Mode

By default, the service runs in read-only mode (`LONGPORT_READONLY=true`) to prevent accidental modifications. Set to `false` to enable write operations:

```bash
LONGPORT_READONLY=false
```

## Project Structure

```
LongportMCPDocker/
├── docker-compose.yml    # Docker Compose configuration
├── Dockerfile           # Docker image definition
├── entrypoint.sh       # Container startup script
├── README.md           # This file
├── .env               # Environment variables (create this)
└── logs/              # Log files (auto-created)
    └── longport-mcp.log.*
```

## Usage

### Starting the Service

```bash
docker-compose up -d
```

### Stopping the Service

```bash
docker-compose down
```

### Restarting the Service

```bash
docker-compose restart
```

### Viewing Logs

```bash
# Follow logs in real-time
docker-compose logs -f

# View recent logs
docker-compose logs --tail=100

# View logs from host directory
tail -f logs/longport-mcp.log.*
```

### Rebuilding After Changes

```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## Accessing the Service

The service exposes an HTTP endpoint for MCP communication:

- **Default URL**: `http://localhost:8000`
- **Protocol**: Server-Sent Events (SSE)

You can configure your MCP client to connect to this endpoint.

## Health Checks

The container includes automatic health checks that:
- Test connectivity to port 8000 every 30 seconds
- Wait 40 seconds before starting checks
- Retry up to 3 times on failure
- Mark container as unhealthy if checks fail

Check health status:

```bash
docker inspect longport-mcp-server --format='{{.State.Health.Status}}'
```

## Troubleshooting

### Container Won't Start

1. Check if the required environment variables are set:
   ```bash
   docker-compose config
   ```

2. Verify credentials are correct in `.env` file

3. Check logs for detailed error messages:
   ```bash
   docker-compose logs
   ```

### Port Already in Use

If port 8000 is already occupied, change the `SERVER_PORT` in `.env`:

```bash
SERVER_PORT=8001
```

### Permission Issues with Logs

Ensure the `logs/` directory has proper permissions:

```bash
chmod 755 logs/
```

## Security Considerations

- ⚠️ **Never commit `.env` file** - Add it to `.gitignore`
- 🔐 **Use read-only mode** by default in production
- 🔒 **Protect your API credentials** - Use Docker secrets or encrypted storage for production
- 🌐 **Firewall configuration** - Restrict access to the service port if exposed publicly

## Building a Minimal Image

To create a minimal Docker image without Docker Compose:

```bash
docker build -t longport-mcp:mini .
```

Run manually:

```bash
docker run -d \
  --name longport-mcp-server \
  -p 8000:8000 \
  -e LONGPORT_APP_KEY=your_key \
  -e LONGPORT_APP_SECRET=your_secret \
  -e LONGPORT_ACCESS_TOKEN=your_token \
  -e LONGPORT_READONLY=true \
  -v $(pwd)/logs:/var/log/longport-mcp \
  longport-mcp:mini
```

## Architecture Support

This project automatically detects and supports the following architectures:

- **x86_64** (Intel/AMD 64-bit)
- **aarch64** (ARM 64-bit, including Apple Silicon)

The correct binary is downloaded during the Docker build process.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is a wrapper for the [Longport MCP server](https://github.com/longportapp/openapi). Please refer to the original project for licensing information.

## Links

- [Longport API Documentation](https://open.longportapp.com/)
- [Longport OpenAPI GitHub](https://github.com/longportapp/openapi)
- [Model Context Protocol](https://modelcontextprotocol.io/)

## Support

For issues related to:
- **This Docker wrapper**: Open an issue in this repository
- **Longport MCP server**: Visit the [official repository](https://github.com/longportapp/openapi)
- **Longport API**: Contact [Longport support](https://open.longportapp.com/)

---

Made with ❤️ for the Longport community
