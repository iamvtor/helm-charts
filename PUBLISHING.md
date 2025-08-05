# Publishing Your Helm Chart to GitHub Container Registry

This guide explains how to publish your ToolJet Helm chart to GitHub Container Registry (ghcr.io) so others can install it directly.

## 🚀 Quick Setup (Automated)

Run the setup script to automate the process:

```bash
cd helm-charts
./scripts/setup-github-pages.sh
```

## 📋 Manual Setup

### Step 1: Prepare Your Repository

1. **Push your changes to GitHub**
   ```bash
   git add .
   git commit -m "Add ToolJet Helm chart with environment variable support"
   git push origin main
   ```

2. **Test your chart locally**
   ```bash
   # Lint the chart
   helm lint charts/tooljet/
   
   # Template the chart
   helm template charts/tooljet/ > /dev/null
   
   # Package the chart
   helm package charts/tooljet/
   ```

### Step 2: Create a Release

1. Go to **Releases** in your repository
2. Click **"Create a new release"**
3. Create a tag (e.g., `v0.1.0`)
4. Add release notes describing your changes
5. Click **"Publish release"**

This will trigger the GitHub Actions workflow that:
- Lints and packages your chart
- Pushes it to GitHub Container Registry (ghcr.io)

### Step 3: Verify the Release

After the workflow completes, your chart will be available at:
```
ghcr.io/YOUR_USERNAME/tooljet
```

## 🔧 Using Your Published Chart

Once published, users can install your chart with:

```bash
# Add your repository
helm repo add tooljet oci://ghcr.io/YOUR_USERNAME

# Update repositories
helm repo update

# Install ToolJet
helm install tooljet tooljet/tooljet
```

## 📝 Updating Your Chart

To release a new version:

1. **Update the chart version** in `charts/tooljet/Chart.yaml`
2. **Commit and push your changes**
3. **Create a new release** with a new tag (e.g., `v0.2.0`)

The workflow will automatically:
- Package the new version
- Push to GitHub Container Registry

## 🛠️ Troubleshooting

### Chart Not Found
- Check that the workflow completed successfully
- Verify the repository URL is correct
- Ensure you're using the OCI protocol: `oci://ghcr.io/YOUR_USERNAME`

### Authentication Issues
- The workflow uses `GITHUB_TOKEN` automatically
- For local testing, you may need to login: `helm registry login ghcr.io` 