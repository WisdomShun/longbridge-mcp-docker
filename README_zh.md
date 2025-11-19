# LongportMCPDocker

[English](README.md) | 简体中文

Longbridge MCP（模型上下文协议）服务器的 Docker 封装，提供简单的部署和管理 Longport API 服务的方式。

## 概述

本项目将 `longport-mcp` 服务器打包到 Docker 容器中，使得部署和运行 Longport API 服务变得简单，并提供适当的配置管理、日志记录和健康检查功能。

## 特性

- 🐳 **基于 Docker 的部署** - 使用 Docker Compose 轻松设置
- 🔒 **安全配置** - 基于环境变量的凭证管理
- 📊 **持久化日志** - 日志存储在挂载卷中
- 💚 **健康监控** - 内置健康检查确保服务可靠性
- 🔄 **自动重启** - 容器失败时自动重启
- 🏗️ **多架构支持** - 支持 x86_64 和 aarch64 (ARM64)

## 前置要求

- Docker Engine (20.10.0 或更高版本)
- Docker Compose (1.29.0 或更高版本)
- Longport API 凭证 (APP_KEY, APP_SECRET, ACCESS_TOKEN)

## 快速开始

### 1. 克隆仓库

```bash
git clone https://github.com/WisdomShun/LongportMCPDocker.git
cd LongportMCPDocker
```

### 2. 配置环境变量

在项目根目录创建 `.env` 文件：

```bash
# Longport API 凭证（必需）
LONGPORT_APP_KEY=your_app_key_here
LONGPORT_APP_SECRET=your_app_secret_here
LONGPORT_ACCESS_TOKEN=your_access_token_here

# 服务器配置（可选）
SERVER_PORT=8000
LONGPORT_READONLY=true
```

### 3. 构建并启动服务

```bash
# 构建 Docker 镜像
docker-compose build

# 启动服务
docker-compose up -d
```

### 4. 验证服务

```bash
# 检查服务状态
docker-compose ps

# 查看日志
docker-compose logs -f longport-mcp

# 检查健康状态
docker-compose exec longport-mcp nc -z localhost 8000 && echo "服务正常"
```

## 配置说明

### 环境变量

| 变量 | 必需 | 默认值 | 描述 |
|----------|----------|---------|-------------|
| `LONGPORT_APP_KEY` | 是 | - | 您的 Longport 应用密钥 |
| `LONGPORT_APP_SECRET` | 是 | - | 您的 Longport 应用密钥 |
| `LONGPORT_ACCESS_TOKEN` | 是 | - | 您的 Longport 访问令牌 |
| `LONGPORT_READONLY` | 否 | `true` | 启用只读模式以确保安全 |
| `SERVER_PORT` | 否 | `8000` | 主机上暴露服务的端口 |

### 只读模式

默认情况下，服务在只读模式下运行（`LONGPORT_READONLY=true`）以防止意外修改。设置为 `false` 以启用写操作：

```bash
LONGPORT_READONLY=false
```

## 项目结构

```
LongportMCPDocker/
├── docker-compose.yml    # Docker Compose 配置
├── Dockerfile           # Docker 镜像定义
├── entrypoint.sh       # 容器启动脚本
├── README.md           # 英文文档
├── README_zh.md        # 中文文档（本文件）
├── .env               # 环境变量（需要创建）
└── logs/              # 日志文件（自动创建）
    └── longport-mcp.log.*
```

## 使用方法

### 启动服务

```bash
docker-compose up -d
```

### 停止服务

```bash
docker-compose down
```

### 重启服务

```bash
docker-compose restart
```

### 查看日志

```bash
# 实时查看日志
docker-compose logs -f

# 查看最近的日志
docker-compose logs --tail=100

# 从主机目录查看日志
tail -f logs/longport-mcp.log.*
```

### 修改后重新构建

```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## 访问服务

服务暴露了一个 HTTP 端点用于 MCP 通信：

- **默认 URL**: `http://localhost:8000`
- **协议**: Server-Sent Events (SSE)

您可以配置 MCP 客户端连接到此端点。

## 健康检查

容器包含自动健康检查功能：
- 每 30 秒测试端口 8000 的连接性
- 等待 40 秒后开始检查
- 失败时最多重试 3 次
- 如果检查失败则标记容器为不健康

查看健康状态：

```bash
docker inspect longport-mcp-server --format='{{.State.Health.Status}}'
```

## 故障排除

### 容器无法启动

1. 检查必需的环境变量是否已设置：
   ```bash
   docker-compose config
   ```

2. 验证 `.env` 文件中的凭证是否正确

3. 查看日志以获取详细错误信息：
   ```bash
   docker-compose logs
   ```

### 端口已被占用

如果端口 8000 已被占用，请在 `.env` 中更改 `SERVER_PORT`：

```bash
SERVER_PORT=8001
```

### 日志权限问题

确保 `logs/` 目录具有适当的权限：

```bash
chmod 755 logs/
```

## 安全注意事项

- ⚠️ **切勿提交 `.env` 文件** - 将其添加到 `.gitignore`
- 🔐 **默认使用只读模式** 在生产环境中
- 🔒 **保护您的 API 凭证** - 在生产环境中使用 Docker secrets 或加密存储
- 🌐 **防火墙配置** - 如果公开暴露服务端口，请限制访问

## 构建最小化镜像

不使用 Docker Compose 创建最小化 Docker 镜像：

```bash
docker build -t longport-mcp:mini .
```

手动运行：

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

## 架构支持

本项目自动检测并支持以下架构：

- **x86_64** (Intel/AMD 64 位)
- **aarch64** (ARM 64 位，包括 Apple Silicon)

在 Docker 构建过程中会自动下载正确的二进制文件。

## 贡献

欢迎贡献！请随时提交 Pull Request。

## 许可证

本项目是 [Longport MCP 服务器](https://github.com/longportapp/openapi) 的封装。有关许可信息，请参考原始项目。

## 相关链接

- [Longport API 文档](https://open.longportapp.com/)
- [Longport OpenAPI GitHub](https://github.com/longportapp/openapi)
- [模型上下文协议](https://modelcontextprotocol.io/)

## 支持

对于以下相关问题：
- **此 Docker 封装**：在本仓库中提交 issue
- **Longport MCP 服务器**：访问[官方仓库](https://github.com/longportapp/openapi)
- **Longport API**：联系 [Longport 支持](https://open.longportapp.com/)

---

用 ❤️ 为 Longport 社区打造
