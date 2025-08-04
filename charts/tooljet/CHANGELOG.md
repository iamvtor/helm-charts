# ToolJet Helm Chart Changelog

## [Unreleased] - 2024-01-XX

### Added
- **New Environment Variable Management**: Added support for individual environment variables through the `environmentVariables` section in values.yaml
- **Existing Secret Support**: Added ability to use existing Kubernetes secrets with `envFrom` instead of creating secrets
- **Flexible Secret Management**: Added `create` flag to control whether the chart creates secrets or uses existing ones
- **Comprehensive Environment Variables**: Added support for all ToolJet environment variables documented in the official documentation
- **Backward Compatibility**: Maintained full backward compatibility with existing `env` section
- **Secret Generation Script**: Added `scripts/generate-secrets.sh` to help users generate required secrets
- **Enhanced Documentation**: Added comprehensive README.md with examples and usage instructions
- **Example Values File**: Added `values-example.yaml` demonstrating all new features

### Changed
- **Secret Template**: Made secret creation conditional based on `apps.tooljet.secret.create` flag
- **Deployment Template**: Updated to support both individual environment variables and existing secrets
- **Values Structure**: Enhanced values.yaml with new configuration options while maintaining backward compatibility

### New Configuration Options

#### Secret Management
```yaml
apps:
  tooljet:
    secret:
      create: true  # or false to use existing secret
      name: "tooljet-server"
      existingSecretName: ""  # name of existing secret when create is false
```

#### Individual Environment Variables
```yaml
environmentVariables:
  TOOLJET_HOST: "https://tooljet.example.com"
  LOCKBOX_MASTER_KEY: "your-32-byte-hex-key"
  SECRET_KEY_BASE: "your-64-byte-hex-key"
  PG_HOST: "postgres.example.com"
  # ... all other ToolJet environment variables
```

### Migration Guide

#### From Previous Versions
1. **No Breaking Changes**: Existing configurations will continue to work without modification
2. **Gradual Migration**: You can gradually migrate from the `env` section to `environmentVariables`
3. **New Variables Take Precedence**: Variables in `environmentVariables` override those in the legacy `env` section

#### Using Existing Secrets
1. Create your secret with all required environment variables
2. Set `apps.tooljet.secret.create: false`
3. Set `apps.tooljet.secret.existingSecretName: "your-secret-name"`

#### Using Individual Variables
1. Set your environment variables in the `environmentVariables` section
2. The chart will create individual `env` entries in the deployment
3. These will override any values from secrets used with `envFrom`

### Security Improvements
- **Secret Rotation**: Easier secret rotation with existing secret support
- **External Secret Management**: Better integration with external secret management solutions
- **Granular Control**: More granular control over which variables are set and how

### Documentation
- Added comprehensive README.md with examples
- Added troubleshooting section
- Added security considerations
- Added migration guide
- Added script documentation

### Files Changed
- `values.yaml` - Added new configuration options
- `templates/secret.yaml` - Made secret creation conditional
- `templates/deployment.yaml` - Added support for individual variables and existing secrets
- `README.md` - Comprehensive documentation
- `values-example.yaml` - Example configuration
- `scripts/generate-secrets.sh` - Secret generation script
- `CHANGELOG.md` - This changelog

### Breaking Changes
- **None**: All changes are backward compatible

### Deprecations
- **None**: The legacy `env` section remains fully supported 