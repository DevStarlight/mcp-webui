# Item Manager - Open WebUI with MCP

Open WebUI integration with MCP (Model Context Protocol) to manage MongoDB data through a proxy.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Quick Start

### 1. Initial Setup

```bash
# Copy environment template
cp env.template .env

# Edit .env with your MongoDB credentials
nano .env
```

### 2. Run Services

#### Raspberry Pi or system without GPU
```bash
# Basic: Open WebUI + MCP only
docker-compose up -d

# With Ollama as Docker container (optional)
docker-compose --profile ollama up -d

# With Cloudflare Tunnel (optional)
docker-compose --profile cloudflared up -d

# With both Ollama and Cloudflare
docker-compose --profile ollama --profile cloudflared up -d
```

#### PC with GPU (NVIDIA)
```bash
# Basic: Open WebUI + MCP only
docker-compose -f docker-compose.gpu.yml up -d

# With Ollama as Docker container (optional)
docker-compose -f docker-compose.gpu.yml --profile ollama up -d

# With Cloudflare Tunnel (optional)
docker-compose -f docker-compose.gpu.yml --profile cloudflared up -d

# With both Ollama and Cloudflare
docker-compose -f docker-compose.gpu.yml --profile ollama --profile cloudflared up -d
```

**💡 If Ollama is installed on host:**
- Don't use the `ollama` profile
- Set `OLLAMA_BASE_URL=http://host.docker.internal:11434` in `.env` (default)

**💡 If Cloudflare is installed on host:**
- Don't use the `cloudflared` profile
- Configure Cloudflare directly on the host

## Services

### open-webui
- **Port**: 3000
- **Version**: 0.6.38
- **GPU**: Enabled in `docker-compose.gpu.yml`, disabled in `docker-compose.yml`

### mcp
- **Port**: 8000
- **Description**: MCP proxy for MongoDB
- **Always active**: Yes

### ollama (optional)
- **Port**: 11434
- **Description**: Ollama service for running local models
- **As container**: Optional, use `--profile ollama`
- **On host**: If Ollama is installed on host, don't use the profile. Open WebUI will connect to `http://host.docker.internal:11434`
- **Auto-download models**: When using the `ollama` profile, models configured in `OLLAMA_MODELS` are downloaded automatically

### cloudflared (optional)
- **Description**: Cloudflare Tunnel for public HTTPS access
- **As container**: Optional, use `--profile cloudflared`
- **On host**: If Cloudflare is installed on host, don't use the profile

## Configuration

### Environment Variables

See `env.template` for all available variables. Key variables:

- `OLLAMA_BASE_URL`: Ollama URL (default: `http://host.docker.internal:11434`)
- `OLLAMA_MODELS`: Models to download automatically (space or comma separated)
- `MONGODB_URI`: MongoDB connection string
- `MONGODB_READONLY`: Read-only mode (false = read/write, true = read-only)
- `CLOUDFLARE_TUNNEL_TOKEN`: Cloudflare Tunnel token (optional)

### Ollama Cloud Models

To use Ollama Cloud models (e.g., `gpt-oss:120b-cloud`), configure them directly in Open WebUI:

1. Go to **Settings** → **Connections** → **API Ollama**
2. Add a new connection:
   - **URL**: `https://ollama.com`
   - **Connection Type**: **External**
   - **Authorization**: **Bearer**
   - **Key**: Your Ollama Cloud API key (get it from https://ollama.com/settings)
3. Save the configuration

**Note**: Local models use the default Ollama connection (`http://host.docker.internal:11434` or `http://ollama:11434`), while cloud models use the `https://ollama.com` connection.

### Cloudflare Tunnel Setup

#### Using Token (Recommended)

1. **Generate a token in Cloudflare Dashboard**:
   - Go to: https://one.dash.cloudflare.com/
   - Navigate to: **Zero Trust** → **Networks** → **Tunnels**
   - Create a new tunnel or select an existing one
   - Copy the generated **token**

2. **Configure the token in `.env`**:
   ```bash
   CLOUDFLARE_TUNNEL_TOKEN=your_token_here
   ```

3. **Start the service**:
   ```bash
   docker-compose --profile cloudflared up -d
   ```

## Project Structure

```
.
├── docker-compose.yml          # For Raspberry Pi (no GPU)
├── docker-compose.gpu.yml       # For PC with GPU
├── env.template                # Environment variables template
├── mcp/                        # MCP Proxy service
│   └── Dockerfile
├── scripts/                    # Utility scripts
│   └── ollama-entrypoint.sh    # Custom Ollama entrypoint
└── open-webui-config/          # Open WebUI configuration
    └── mcp/
```

### Downloading Ollama models

#### Automatically (recommended)
When using the `ollama` profile, models are downloaded automatically on container start:

1. **Configure models in `.env`**:
   ```bash
   OLLAMA_MODELS=llama3.2 mistral qwen2.5
   ```

2. **Start with ollama profile**:
   ```bash
   docker-compose --profile ollama up -d
   ```

3. **Check download**:
   ```bash
   docker-compose logs ollama
   ```

**Recommended models:**
- `llama3.2` - Balanced model
- `mistral` - Good performance
- `qwen2.5` - Excellent for Spanish
- `phi3` - Small and fast
