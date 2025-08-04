#!/bin/bash

# ToolJet Secret Generation Script
# This script helps generate the required secrets for ToolJet deployment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to generate random hex string
generate_hex() {
    local length=$1
    if command_exists openssl; then
        openssl rand -hex $length
    elif command_exists head; then
        head -c $((length * 2)) /dev/urandom | xxd -p -c $((length * 2))
    else
        print_error "Neither openssl nor xxd found. Please install one of them."
        exit 1
    fi
}

# Function to create Kubernetes secret
create_k8s_secret() {
    local secret_name=$1
    local namespace=$2
    
    print_info "Creating Kubernetes secret: $secret_name"
    
    # Check if secret already exists
    if kubectl get secret "$secret_name" -n "$namespace" >/dev/null 2>&1; then
        print_warning "Secret $secret_name already exists in namespace $namespace"
        read -p "Do you want to delete and recreate it? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            kubectl delete secret "$secret_name" -n "$namespace"
        else
            print_info "Skipping secret creation"
            return 0
        fi
    fi
    
    # Create secret with all environment variables
    kubectl create secret generic "$secret_name" \
        --from-literal=TOOLJET_HOST="$TOOLJET_HOST" \
        --from-literal=LOCKBOX_MASTER_KEY="$LOCKBOX_MASTER_KEY" \
        --from-literal=SECRET_KEY_BASE="$SECRET_KEY_BASE" \
        --from-literal=PG_HOST="$PG_HOST" \
        --from-literal=PG_PORT="$PG_PORT" \
        --from-literal=PG_USER="$PG_USER" \
        --from-literal=PG_PASS="$PG_PASS" \
        --from-literal=PG_DB="$PG_DB" \
        --from-literal=ENABLE_TOOLJET_DB="$ENABLE_TOOLJET_DB" \
        --from-literal=TOOLJET_DB_HOST="$TOOLJET_DB_HOST" \
        --from-literal=TOOLJET_DB_USER="$TOOLJET_DB_USER" \
        --from-literal=TOOLJET_DB_PASS="$TOOLJET_DB_PASS" \
        --from-literal=TOOLJET_DB="$TOOLJET_DB" \
        --from-literal=PGRST_HOST="$PGRST_HOST" \
        --from-literal=PGRST_JWT_SECRET="$PGRST_JWT_SECRET" \
        --from-literal=PGRST_DB_URI="$PGRST_DB_URI" \
        --from-literal=REDIS_HOST="$REDIS_HOST" \
        --from-literal=REDIS_PORT="$REDIS_PORT" \
        --from-literal=REDIS_USER="$REDIS_USER" \
        --from-literal=REDIS_PASSWORD="$REDIS_PASSWORD" \
        --from-literal=DEPLOYMENT_PLATFORM="k8s:helm" \
        -n "$namespace"
    
    print_success "Secret $secret_name created successfully in namespace $namespace"
}

# Function to generate values.yaml snippet
generate_values_snippet() {
    local secret_name=$1
    cat << EOF

# Add this to your values.yaml to use the existing secret:
apps:
  tooljet:
    secret:
      create: false
      existingSecretName: "$secret_name"

# Or use individual environment variables:
environmentVariables:
  TOOLJET_HOST: "$TOOLJET_HOST"
  LOCKBOX_MASTER_KEY: "$LOCKBOX_MASTER_KEY"
  SECRET_KEY_BASE: "$SECRET_KEY_BASE"
  PG_HOST: "$PG_HOST"
  PG_PORT: "$PG_PORT"
  PG_USER: "$PG_USER"
  PG_PASS: "$PG_PASS"
  PG_DB: "$PG_DB"
  ENABLE_TOOLJET_DB: "$ENABLE_TOOLJET_DB"
  TOOLJET_DB_HOST: "$TOOLJET_DB_HOST"
  TOOLJET_DB_USER: "$TOOLJET_DB_USER"
  TOOLJET_DB_PASS: "$TOOLJET_DB_PASS"
  TOOLJET_DB: "$TOOLJET_DB"
  PGRST_HOST: "$PGRST_HOST"
  PGRST_JWT_SECRET: "$PGRST_JWT_SECRET"
  PGRST_DB_URI: "$PGRST_DB_URI"
  REDIS_HOST: "$REDIS_HOST"
  REDIS_PORT: "$REDIS_PORT"
  REDIS_USER: "$REDIS_USER"
  REDIS_PASSWORD: "$REDIS_PASSWORD"
  DEPLOYMENT_PLATFORM: "k8s:helm"
EOF
}

# Main script
main() {
    print_info "ToolJet Secret Generation Script"
    print_info "This script will help you generate the required secrets for ToolJet deployment"
    echo
    
    # Check prerequisites
    if ! command_exists kubectl; then
        print_error "kubectl is not installed or not in PATH"
        exit 1
    fi
    
    # Get user input
    print_info "Please provide the following information:"
    echo
    
    # ToolJet Host
    read -p "ToolJet Host URL (e.g., https://tooljet.example.com): " TOOLJET_HOST
    if [[ -z "$TOOLJET_HOST" ]]; then
        print_error "ToolJet Host is required"
        exit 1
    fi
    
    # Database configuration
    print_info "Database Configuration:"
    read -p "PostgreSQL Host: " PG_HOST
    read -p "PostgreSQL Port [5432]: " PG_PORT
    PG_PORT=${PG_PORT:-5432}
    read -p "PostgreSQL User: " PG_USER
    read -s -p "PostgreSQL Password: " PG_PASS
    echo
    read -p "PostgreSQL Database: " PG_DB
    
    # ToolJet Database configuration
    print_info "ToolJet Database Configuration:"
    read -p "ToolJet Database Host [$PG_HOST]: " TOOLJET_DB_HOST
    TOOLJET_DB_HOST=${TOOLJET_DB_HOST:-$PG_HOST}
    read -p "ToolJet Database User [$PG_USER]: " TOOLJET_DB_USER
    TOOLJET_DB_USER=${TOOLJET_DB_USER:-$PG_USER}
    read -s -p "ToolJet Database Password: " TOOLJET_DB_PASS
    echo
    if [[ -z "$TOOLJET_DB_PASS" ]]; then
        TOOLJET_DB_PASS="$PG_PASS"
    fi
    read -p "ToolJet Database Name [tooljet_db]: " TOOLJET_DB
    TOOLJET_DB=${TOOLJET_DB:-tooljet_db}
    
    # Redis configuration
    print_info "Redis Configuration:"
    read -p "Redis Host [redis-master]: " REDIS_HOST
    REDIS_HOST=${REDIS_HOST:-redis-master}
    read -p "Redis Port [6379]: " REDIS_PORT
    REDIS_PORT=${REDIS_PORT:-6379}
    read -p "Redis User [default]: " REDIS_USER
    REDIS_USER=${REDIS_USER:-default}
    read -s -p "Redis Password: " REDIS_PASSWORD
    echo
    
    # PostgREST configuration
    print_info "PostgREST Configuration:"
    read -p "PostgREST Host [tooljet-postgrest:3001]: " PGRST_HOST
    PGRST_HOST=${PGRST_HOST:-tooljet-postgrest:3001}
    
    # Generate secrets
    print_info "Generating secrets..."
    LOCKBOX_MASTER_KEY=$(generate_hex 32)
    SECRET_KEY_BASE=$(generate_hex 64)
    PGRST_JWT_SECRET=$(generate_hex 32)
    
    # Set default values
    ENABLE_TOOLJET_DB=${ENABLE_TOOLJET_DB:-true}
    PGRST_DB_URI="postgres://$TOOLJET_DB_USER:$TOOLJET_DB_PASS@$TOOLJET_DB_HOST:$PG_PORT/$TOOLJET_DB"
    
    print_success "Secrets generated successfully!"
    echo
    
    # Display generated secrets
    print_info "Generated Secrets:"
    echo "LOCKBOX_MASTER_KEY: $LOCKBOX_MASTER_KEY"
    echo "SECRET_KEY_BASE: $SECRET_KEY_BASE"
    echo "PGRST_JWT_SECRET: $PGRST_JWT_SECRET"
    echo
    
    # Ask if user wants to create Kubernetes secret
    read -p "Do you want to create a Kubernetes secret? (Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        read -p "Secret name [tooljet-secret]: " SECRET_NAME
        SECRET_NAME=${SECRET_NAME:-tooljet-secret}
        read -p "Namespace [default]: " NAMESPACE
        NAMESPACE=${NAMESPACE:-default}
        
        create_k8s_secret "$SECRET_NAME" "$NAMESPACE"
    fi
    
    # Generate values.yaml snippet
    print_info "Generating values.yaml snippet..."
    generate_values_snippet "${SECRET_NAME:-tooljet-secret}" > tooljet-values-snippet.yaml
    
    print_success "Values snippet saved to tooljet-values-snippet.yaml"
    echo
    print_info "You can now use this snippet in your values.yaml file"
    print_info "Or use the existing secret with:"
    echo "helm install tooljet ./charts/tooljet -f tooljet-values-snippet.yaml"
}

# Run main function
main "$@" 