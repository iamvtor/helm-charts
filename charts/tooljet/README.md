# ToolJet Helm Chart

This Helm chart deploys ToolJet, an open-source low-code platform for building business applications.

## Features

- Deploy ToolJet with PostgreSQL, Redis, and PostgREST
- Support for external databases
- Configurable environment variables
- Optional secret management
- Support for existing secrets with `envFrom`

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- PostgreSQL database (included or external)
- Redis (optional, included or external)

## Installation

### Basic Installation

```bash
helm install tooljet ./charts/tooljet
```

### With Custom Values

```bash
helm install tooljet ./charts/tooljet -f values.yaml
```

## Configuration

### Environment Variables

The chart supports two ways to configure environment variables:

#### 1. Individual Environment Variables (Recommended)

You can set individual environment variables directly in the `environmentVariables` section:

```yaml
environmentVariables:
  TOOLJET_HOST: "https://tooljet.example.com"
  PG_HOST: "postgres.example.com"
  PG_USER: "tooljet"
  PG_PASS: "password"
  PG_DB: "tooljet_prod"
  LOCKBOX_MASTER_KEY: "your-32-byte-hex-key"
  SECRET_KEY_BASE: "your-64-byte-hex-key"
  ENABLE_TOOLJET_DB: "true"
  TOOLJET_DB_HOST: "postgres.example.com"
  TOOLJET_DB_USER: "tooljet"
  TOOLJET_DB_PASS: "password"
  TOOLJET_DB: "tooljet_db"
  PGRST_HOST: "tooljet-postgrest:3001"
  PGRST_JWT_SECRET: "your-jwt-secret"
  PGRST_DB_URI: "postgres://user:pass@host:port/db"
```

#### 2. Using Existing Secrets with envFrom

You can use an existing secret that contains all environment variables:

```yaml
apps:
  tooljet:
    secret:
      create: false  # Disable secret creation
      existingSecretName: "my-tooljet-secret"  # Use existing secret
```

The existing secret should contain all required environment variables as key-value pairs.

### Secret Management

#### Option 1: Chart-Created Secret (Default)

The chart creates a secret with the following variables:

```yaml
apps:
  tooljet:
    secret:
      create: true  # Default
      name: "tooljet-server"
      data:
        lockbox_key: "0123456789ABCDEF"
        secret_key_base: "0123456789ABCDEF"
```

#### Option 2: Use Existing Secret

```yaml
apps:
  tooljet:
    secret:
      create: false
      existingSecretName: "my-existing-secret"
```

### Database Configuration

#### Using Included PostgreSQL

```yaml
postgresql:
  enabled: true
  auth:
    username: "postgres"
    postgresPassword: "postgres"
    database: "tooljet_prod"
```

#### Using External PostgreSQL

```yaml
external_postgresql:
  enabled: true
  PG_HOST: "postgres.example.com"
  PG_USER: "tooljet"
  PG_PASS: "password"
  PG_PORT: "5432"
  PG_DB: "tooljet_prod"
```

### Redis Configuration

#### Using Included Redis

```yaml
redis:
  enabled: true
  auth:
    enabled: true
    password: "tooljet"
```

#### Using External Redis

Set the Redis configuration in `environmentVariables`:

```yaml
environmentVariables:
  REDIS_HOST: "redis.example.com"
  REDIS_PORT: "6379"
  REDIS_USER: "default"
  REDIS_PASSWORD: "password"
```

## Required Environment Variables

Based on the [ToolJet documentation](https://docs.tooljet.ai/docs/setup/env-vars), the following variables are required:

### ToolJet Server (Required)

| Variable | Description | Example |
|----------|-------------|---------|
| `TOOLJET_HOST` | Public URL of ToolJet client | `https://app.tooljet.com` |
| `LOCKBOX_MASTER_KEY` | 32-byte hex string for encryption | `openssl rand -hex 32` |
| `SECRET_KEY_BASE` | 64-byte hex string for session cookies | `openssl rand -hex 64` |

### Database Configuration (Required)

| Variable | Description | Example |
|----------|-------------|---------|
| `PG_HOST` | PostgreSQL database host | `postgres.example.com` |
| `PG_DB` | Database name | `tooljet_prod` |
| `PG_USER` | Database username | `tooljet` |
| `PG_PASS` | Database password | `password` |
| `PG_PORT` | Database port | `5432` |

### ToolJet Database (Required)

| Variable | Description | Example |
|----------|-------------|---------|
| `TOOLJET_DB` | ToolJet database name | `tooljet_db` |
| `TOOLJET_DB_HOST` | ToolJet database host | `postgres.example.com` |
| `TOOLJET_DB_USER` | ToolJet database username | `tooljet` |
| `TOOLJET_DB_PASS` | ToolJet database password | `password` |
| `TOOLJET_DB_PORT` | ToolJet database port | `5432` |

### PostgREST Configuration (Required)

| Variable | Description | Example |
|----------|-------------|---------|
| `PGRST_JWT_SECRET` | JWT token for authentication | `openssl rand -hex 32` |
| `PGRST_DB_URI` | Database connection string | `postgres://user:pass@host:port/db` |

## Examples

### Example 1: Basic Installation with Individual Variables

```yaml
environmentVariables:
  TOOLJET_HOST: "https://tooljet.example.com"
  LOCKBOX_MASTER_KEY: "0123456789ABCDEF0123456789ABCDEF"
  SECRET_KEY_BASE: "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF"
  PG_HOST: "postgres.example.com"
  PG_USER: "tooljet"
  PG_PASS: "password"
  PG_DB: "tooljet_prod"
  TOOLJET_DB_HOST: "postgres.example.com"
  TOOLJET_DB_USER: "tooljet"
  TOOLJET_DB_PASS: "password"
  TOOLJET_DB: "tooljet_db"
  PGRST_JWT_SECRET: "0123456789ABCDEF0123456789ABCDEF"
  PGRST_DB_URI: "postgres://tooljet:password@postgres.example.com:5432/tooljet_db"
```

### Example 2: Using Existing Secret

```yaml
apps:
  tooljet:
    secret:
      create: false
      existingSecretName: "my-tooljet-secret"

# The secret should contain all environment variables
# kubectl create secret generic my-tooljet-secret \
#   --from-literal=TOOLJET_HOST=https://tooljet.example.com \
#   --from-literal=LOCKBOX_MASTER_KEY=0123456789ABCDEF0123456789ABCDEF \
#   --from-literal=SECRET_KEY_BASE=0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF \
#   --from-literal=PG_HOST=postgres.example.com \
#   --from-literal=PG_USER=tooljet \
#   --from-literal=PG_PASS=password \
#   --from-literal=PG_DB=tooljet_prod
```

### Example 3: Mixed Approach

```yaml
apps:
  tooljet:
    secret:
      create: false
      existingSecretName: "my-tooljet-secret"

environmentVariables:
  # Override specific variables from the secret
  TOOLJET_HOST: "https://custom.tooljet.example.com"
  LOG_LEVEL: "debug"
```

## Migration from Previous Versions

The chart maintains backward compatibility with the legacy `env` section. If you're upgrading from a previous version:

1. Your existing `env` configuration will continue to work
2. You can gradually migrate to the new `environmentVariables` section
3. The new variables take precedence over legacy ones

## Security Considerations

1. **Never commit secrets to version control**
2. Use Kubernetes secrets or external secret management solutions
3. Rotate `LOCKBOX_MASTER_KEY` and `SECRET_KEY_BASE` regularly
4. Use strong passwords for database connections
5. Enable TLS for database connections in production

## Troubleshooting

### Common Issues

1. **Database Connection Errors**: Verify database credentials and network connectivity
2. **Secret Not Found**: Ensure the existing secret exists and has the correct name
3. **Environment Variable Conflicts**: Check for duplicate variable definitions

### Debug Commands

```bash
# Check pod logs
kubectl logs -f deployment/tooljet

# Check environment variables
kubectl exec deployment/tooljet -- env | grep -E "(PG_|TOOLJET_|PGRST_)"

# Check secret contents
kubectl get secret tooljet-server -o yaml
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This chart is licensed under the same license as ToolJet. 