# Publishing Your Helm Chart to GitHub Pages

This guide explains how to publish your ToolJet Helm chart to GitHub Pages so others can install it directly, including with ArgoCD.

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
- Creates the Helm repository index
- Deploys it to the `gh-pages` branch

### Step 3: Enable GitHub Pages

**Wait for the workflow to complete first** (check the Actions tab), then:

1. Go to your GitHub repository: `https://github.com/YOUR_USERNAME/helm-charts`
2. Go to **Settings** > **Pages**
3. Set **Source** to "Deploy from a branch"
4. Set **Branch** to "gh-pages" and **folder** to "/"
5. Click **Save**

### Step 4: Verify the Release

After both the workflow completes and GitHub Pages is enabled, your chart will be available at:
```
https://YOUR_USERNAME.github.io/helm-charts
```

## 🔧 Using Your Published Chart

Once published, users can install your chart with:

```bash
# Add your repository
helm repo add tooljet https://YOUR_USERNAME.github.io/helm-charts

# Update repositories
helm repo update

# Install ToolJet
helm install tooljet tooljet/tooljet
```

### ArgoCD Installation

For ArgoCD users, create an Application manifest:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: tooljet
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://YOUR_USERNAME.github.io/helm-charts
    chart: tooljet
    targetRevision: 3.0.12
    helm:
      values: |
        environmentVariables:
          TOOLJET_HOST: "https://tooljet.example.com"
          # ... other variables
  destination:
    server: https://kubernetes.default.svc
    namespace: tooljet
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## 📝 Updating Your Chart

To release a new version:

1. **Update the chart version** in `charts/tooljet/Chart.yaml`
2. **Commit and push your changes**
3. **Create a new release** with a new tag (e.g., `v0.2.0`)

The workflow will automatically:
- Package the new version
- Update the repository index
- Deploy to GitHub Pages

## 🛠️ Troubleshooting

### Chart Not Found
- Ensure GitHub Pages is enabled and deployed
- Check that the workflow completed successfully
- Verify the repository URL is correct

### Workflow Fails
- Check the Actions tab for error details
- Ensure all dependencies are properly configured
- Verify the chart passes linting locally

### GitHub Pages Not Working
- **Important**: The `gh-pages` branch is created by the workflow, not manually
- Wait for the workflow to complete before setting up GitHub Pages
- Check that the Pages source is set to gh-pages branch
- Wait a few minutes for the initial deployment

### gh-pages Branch Doesn't Exist
- This is normal! The branch is created by the GitHub Actions workflow
- Create a release first to trigger the workflow
- The workflow will create the `gh-pages` branch automatically
- Then you can set up GitHub Pages to use that branch 