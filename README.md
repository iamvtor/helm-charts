# ToolJet Helm Charts

This repository contains Helm charts for deploying ToolJet, an open-source low-code platform for building business applications.

## 📦 Published Chart

The ToolJet Helm chart is published and available for installation from GitHub Container Registry (ghcr.io).

### Quick Start

```bash
# Add the repository
helm repo add tooljet oci://ghcr.io/iamvtor

# Update repositories
helm repo update

# Install ToolJet
helm install tooljet tooljet/tooljet
```

### Installation with Custom Values

```bash
# Download the values file
helm show values tooljet/tooljet > values.yaml

# Edit values.yaml with your configuration
# Then install with custom values
helm install tooljet tooljet/tooljet -f values.yaml
```

## 🚀 Features

- **Flexible Environment Variables**: Support for individual environment variables or existing secrets
- **External Database Support**: Use external PostgreSQL and Redis instances
- **Secret Management**: Use existing secrets with `envFrom` or let the chart create them
- **Comprehensive Configuration**: Support for all ToolJet environment variables
- **Backward Compatible**: Works with existing configurations

## 📋 Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- PostgreSQL database (included or external)
- Redis (optional, included or external)

## 🔧 Configuration

### Using Individual Environment Variables

```yaml
environmentVariables:
  TOOLJET_HOST: "https://tooljet.example.com"
  LOCKBOX_MASTER_KEY: "your-32-byte-hex-key"
  SECRET_KEY_BASE: "your-64-byte-hex-key"
  PG_HOST: "postgres.example.com"
  PG_USER: "tooljet"
  PG_PASS: "password"
  PG_DB: "tooljet_prod"
```

### Using Existing Secret

```yaml
apps:
  tooljet:
    secret:
      create: false
      existingSecretName: "my-tooljet-secret"
```

### External Database

```yaml
external_postgresql:
  enabled: true
  PG_HOST: "postgres.example.com"
  PG_USER: "tooljet"
  PG_PASS: "password"
  PG_PORT: "5432"
  PG_DB: "tooljet_prod"
```

## 📚 Documentation

For detailed documentation, see the [chart README](./charts/tooljet/README.md).

## 🔄 Upgrading

```bash
# Update the repository
helm repo update

# Upgrade the release
helm upgrade tooljet tooljet/tooljet
```

## 🛠️ Development

### Local Development

```bash
# Clone the repository
git clone https://github.com/iamvtor/helm-charts.git
cd helm-charts

# Install dependencies
helm dependency update charts/tooljet/

# Lint the chart
helm lint charts/tooljet/

# Template the chart
helm template charts/tooljet/ > /dev/null

# Package the chart
helm package charts/tooljet/
```

### Testing

```bash
# Install in test mode
helm install tooljet charts/tooljet/ --dry-run

# Test with custom values
helm install tooljet charts/tooljet/ -f charts/tooljet/values-example.yaml --dry-run
```

## 📝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the same license as ToolJet.

## 🔗 Links

- [ToolJet Documentation](https://docs.tooljet.ai/)
- [ToolJet GitHub Repository](https://github.com/ToolJet/ToolJet)
- [Helm Documentation](https://helm.sh/docs/)
