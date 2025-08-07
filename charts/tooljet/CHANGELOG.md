# ToolJet Helm Chart Changelog

## [3.0.13] - 2024-08-04

### Fixed
- **PostgreSQL and Redis Dependencies**: Fixed issue where PostgreSQL and Redis were being created even when `enabled: false`
  - Set `postgresql.enabled: false` and `redis.enabled: false` by default
  - Dependencies now properly respect the enabled flags
- **Secret Creation Logic**: Fixed multiple secrets being created unnecessarily
  - `tooljet-server` secret only created when `apps.tooljet.secret.create: true`
  - `tooljet-postgresql` secret only created when PostgreSQL is enabled AND PostgREST secret creation is enabled
  - `tooljet-redis` secret only created when Redis is enabled
- **Deployment Template**: Fixed deployment template to properly handle existing secrets
  - Use `envFrom` with existing secret when `apps.tooljet.secret.create: false` and `existingSecretName` is specified
  - Only add individual environment variables when not using existing secrets
  - Properly handle Redis password only when Redis is enabled

### Added
- **External Database Example**: Added `values-external-db.yaml` with complete example for external databases and existing secrets
- **Enhanced Documentation**: Updated README with bug fixes documentation and configuration examples

### Changed
- **Default Values**: Changed default values to disable internal PostgreSQL and Redis by default
- **Secret Template Logic**: Improved secret creation conditions to be more precise

## [Unreleased] - 2024-01-XX

### Added
- **New Environment Variable Management**: Added support for individual environment variables through the `environmentVariables` section in values.yaml
- **Existing Secret Support**: Added ability to use existing Kubernetes secrets with `envFrom` instead of creating secrets
- **Flexible Secret Management**: Added `create` flag to control whether the chart creates secrets or uses existing ones
- **PostgREST Secret Management**: Added support for existing PostgREST secrets with `envFrom` and individual environment variables
- **Comprehensive Environment Variables**: Added support for all ToolJet environment variables documented in the official documentation
- **Backward Compatibility**: Maintained full backward compatibility with existing `env` section
- **Secret Generation Script**: Added `scripts/generate-secrets.sh` to help users generate required secrets
- **Enhanced Documentation**: Added comprehensive README.md with examples and usage instructions
- **Example Values File**: Added `values-example.yaml` demonstrating all new features

### Changed
- **Secret Template**: Made secret creation conditional based on `apps.tooljet.secret.create` flag
- **PostgREST Secret Template**: Made PostgREST secret creation conditional based on `postgrest.secret.create` flag
- **Deployment Template**: Updated to support both individual environment variables and existing secrets
- **PostgREST Deployment Template**: Updated to support both individual environment variables and existing secrets
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

#### PostgREST Secret Management
```yaml
postgrest:
  secret:
    create: true  # or false to use existing secret
    existingSecretName: ""  # name of existing secret when create is false
```

#### Individual Environment Variables
```yaml
environmentVariables:
  TOOLJET_HOST: "https://tooljet.example.com"
  LOCKBOX_MASTER_KEY: "your-32-byte-hex-key"
  SECRET_KEY_BASE: "your-64-byte-hex-key"
  PG_HOST: "postgres.example.com"
  PGRST_DB_URI: "postgres://user:pass@host:port/db"
  PGRST_JWT_SECRET: "your-jwt-secret"
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

#### Using Existing PostgREST Secrets
1. Create your PostgREST secret with `PGRST_DB_URI` and `PGRST_JWT_SECRET`
2. Set `postgrest.secret.create: false`
3. Set `postgrest.secret.existingSecretName: "your-postgrest-secret-name"`

#### Using Individual Variables
1. Set your environment variables in the `environmentVariables` section
2. The chart will create individual `env` entries in the deployment
3. These will override any values from secrets used with `envFrom`

### Security Improvements
- **Secret Rotation**: Easier secret rotation with existing secret support
- **External Secret Management**: Better integration with external secret management solutions
- **Granular Control**: More granular control over which variables are set and how
- **PostgREST Security**: Enhanced PostgREST configuration security with secret management

### Documentation
- Added comprehensive README.md with examples
- Added troubleshooting section
- Added security considerations
- Added migration guide
- Added script documentation
- Added PostgREST secret management documentation

### Files Changed
- `values.yaml` - Added new configuration options
- `templates/secret.yaml` - Made secret creation conditional
- `templates/deployment.yaml` - Added support for individual variables and existing secrets
- `templates/deployment-pgrst.yml` - Added support for individual variables and existing secrets
- `README.md` - Comprehensive documentation
- `values-example.yaml` - Example configuration
- `scripts/generate-secrets.sh` - Secret generation script
- `CHANGELOG.md` - This changelog

### Breaking Changes
- **None**: All changes are backward compatible

### Deprecations
- **None**: The legacy `env` section remains fully supported 