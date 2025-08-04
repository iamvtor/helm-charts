#!/bin/bash

# Setup GitHub Pages for Helm Chart Repository
# This script helps you set up GitHub Pages to serve your Helm chart

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

# Function to check if we're in a git repository
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "This is not a git repository. Please run this script from a git repository."
        exit 1
    fi
}

# Function to get repository information
get_repo_info() {
    local remote_url=$(git config --get remote.origin.url)
    if [[ $remote_url =~ github\.com[:/]([^/]+)/([^/]+)\.git ]]; then
        GITHUB_USERNAME="${BASH_REMATCH[1]}"
        REPO_NAME="${BASH_REMATCH[2]}"
        if [[ $REPO_NAME == *.git ]]; then
            REPO_NAME="${REPO_NAME%.git}"
        fi
    else
        print_error "Could not determine GitHub repository information from remote URL: $remote_url"
        exit 1
    fi
}

# Function to check if tag exists
tag_exists() {
    local tag=$1
    git rev-parse "v$tag" >/dev/null 2>&1
}

# Function to get next version
get_next_version() {
    local current_version=$1
    local major=$(echo $current_version | cut -d. -f1)
    local minor=$(echo $current_version | cut -d. -f2)
    local patch=$(echo $current_version | cut -d. -f3)
    echo "$major.$minor.$((patch + 1))"
}

# Function to create initial release
create_initial_release() {
    print_info "Creating release..."
    
    # Check if we have uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        print_warning "You have uncommitted changes. Please commit them first."
        read -p "Do you want to continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    # Get current version from Chart.yaml if it exists
    local chart_version="0.1.0"
    if [[ -f "charts/tooljet/Chart.yaml" ]]; then
        chart_version=$(grep "^version:" charts/tooljet/Chart.yaml | awk '{print $2}')
        print_info "Found version $chart_version in Chart.yaml"
    fi
    
    # Check if tag already exists
    if tag_exists "$chart_version"; then
        print_warning "Tag v$chart_version already exists"
        echo "Available options:"
        echo "1. Use a new version (increment patch)"
        echo "2. Use a custom version"
        echo "3. Skip tag creation"
        read -p "Choose option (1-3): " -n 1 -r
        echo
        
        case $REPLY in
            1)
                chart_version=$(get_next_version "$chart_version")
                print_info "Using new version: $chart_version"
                ;;
            2)
                read -p "Enter custom version (e.g., 0.2.0): " chart_version
                ;;
            3)
                print_info "Skipping tag creation"
                return 0
                ;;
            *)
                print_error "Invalid option"
                exit 1
                ;;
        esac
    fi
    
    # Create and push tag
    git tag -a "v$chart_version" -m "Release v$chart_version"
    git push origin "v$chart_version"
    
    print_success "Tag v$chart_version created and pushed"
    print_info "Now create a GitHub release from this tag to trigger the workflow"
}

# Function to test the chart locally
test_chart() {
    print_info "Testing the chart locally..."
    
    if ! command_exists helm; then
        print_error "Helm is not installed. Please install Helm first."
        exit 1
    fi
    
    # Lint the chart
    print_info "Linting chart..."
    helm lint charts/tooljet/
    
    # Template the chart
    print_info "Templating chart..."
    helm template charts/tooljet/ > /dev/null
    
    # Package the chart
    print_info "Packaging chart..."
    helm package charts/tooljet/
    
    print_success "Chart tests passed!"
}

# Function to update README with correct repository URL
update_readme() {
    print_info "Updating README with repository information..."
    
    local repo_url="https://$GITHUB_USERNAME.github.io/$REPO_NAME"
    
    # Update the README.md file
    sed -i.bak "s|YOUR_GITHUB_USERNAME|$GITHUB_USERNAME|g" README.md
    sed -i.bak "s|YOUR_USERNAME|$GITHUB_USERNAME|g" README.md
    
    # Remove backup file
    rm -f README.md.bak
    
    print_success "README updated with repository information"
}

# Function to show next steps
show_next_steps() {
    print_success "Setup completed!"
    echo
    print_info "Next steps:"
    echo "1. Go to your GitHub repository: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
    echo "2. Create a GitHub release to trigger the workflow:"
    echo "   - Go to Releases"
    echo "   - Click 'Create a new release'"
    echo "   - Choose the tag that was just created"
    echo "   - Add release notes"
    echo "   - Click 'Publish release'"
    echo "3. Wait for the workflow to complete (check Actions tab)"
    echo "4. After the workflow completes, set up GitHub Pages:"
    echo "   - Go to Settings > Pages"
    echo "   - Set Source to 'Deploy from a branch'"
    echo "   - Set Branch to 'gh-pages' and folder to '/'"
    echo "   - Click Save"
    echo
    print_info "After the workflow completes, your chart will be available at:"
    echo "https://$GITHUB_USERNAME.github.io/$REPO_NAME"
    echo
    print_info "Users can then install your chart with:"
    echo "helm repo add tooljet https://$GITHUB_USERNAME.github.io/$REPO_NAME"
    echo "helm install tooljet tooljet/tooljet"
}

# Main function
main() {
    print_info "GitHub Pages Setup for Helm Chart Repository"
    print_info "This script will help you set up GitHub Pages to serve your Helm chart"
    echo
    
    # Check prerequisites
    if ! command_exists git; then
        print_error "Git is not installed or not in PATH"
        exit 1
    fi
    
    # Check if we're in a git repository
    check_git_repo
    
    # Get repository information
    get_repo_info
    
    print_info "Repository: $GITHUB_USERNAME/$REPO_NAME"
    echo
    
    # Test the chart
    test_chart
    echo
    
    # Update README
    update_readme
    echo
    
    # Create initial release
    create_initial_release
    echo
    
    # Show next steps
    show_next_steps
}

# Run main function
main "$@" 