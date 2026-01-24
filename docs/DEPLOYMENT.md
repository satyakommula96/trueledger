# GitHub Pages Deployment Guide

This guide explains how to deploy the TrueCash documentation to GitHub Pages.

## 🚀 Automatic Deployment (Recommended)

The documentation is automatically deployed to GitHub Pages whenever changes are pushed to the `main` branch.

### How It Works

1. **Trigger**: Push to `main` branch with changes to `docs/` or `mkdocs.yml`
2. **Build**: GitHub Actions builds the documentation using MkDocs
3. **Deploy**: The built site is deployed to the `gh-pages` branch
4. **Live**: Documentation is available at https://satyakommula96.github.io/truecash/

### Workflow File

The deployment is handled by `.github/workflows/deploy-docs.yml`:

```yaml
name: Deploy Documentation

on:
  push:
    branches:
      - main
    paths:
      - 'docs/**'
      - 'mkdocs.yml'
  workflow_dispatch:  # Manual trigger option
```

### Manual Trigger

You can also manually trigger the deployment from GitHub:

1. Go to **Actions** tab in GitHub
2. Select **Deploy Documentation** workflow
3. Click **Run workflow**
4. Select `main` branch
5. Click **Run workflow**

## 🔧 One-Time Setup

### 1. Enable GitHub Pages

1. Go to your repository on GitHub
2. Navigate to **Settings** → **Pages**
3. Under **Source**, select:
   - **Branch**: `gh-pages`
   - **Folder**: `/ (root)`
4. Click **Save**

### 2. Configure Permissions

The workflow needs write permissions to deploy:

1. Go to **Settings** → **Actions** → **General**
2. Scroll to **Workflow permissions**
3. Select **Read and write permissions**
4. Click **Save**

### 3. First Deployment

After setup, trigger the first deployment:

```bash
# Option 1: Push to main
git add .
git commit -m "docs: setup GitHub Pages deployment"
git push origin main

# Option 2: Manual deployment (see below)
```

## 💻 Manual Deployment (Local)

You can also deploy manually from your local machine:

### Prerequisites

```bash
# Install MkDocs and dependencies
pip install -r requirements.txt
```

### Deploy

```bash
# Build and deploy to GitHub Pages
mkdocs gh-deploy

# With custom commit message
mkdocs gh-deploy -m "docs: update documentation"
```

This will:
1. Build the documentation
2. Push to `gh-pages` branch
3. Make it live at https://satyakommula96.github.io/truecash/

## 🔍 Verify Deployment

### Check Build Status

1. Go to **Actions** tab
2. Find the latest **Deploy Documentation** workflow run
3. Check if it completed successfully (green checkmark)

### View Live Site

Visit: https://satyakommula96.github.io/truecash/

### Check gh-pages Branch

```bash
# View gh-pages branch
git fetch origin
git checkout gh-pages

# Return to main
git checkout main
```

## 🛠️ Troubleshooting

### Deployment Fails

**Problem**: Workflow fails with permission error

**Solution**: 
1. Check **Settings** → **Actions** → **General**
2. Ensure **Read and write permissions** is selected

---

**Problem**: Pages not updating

**Solution**:
1. Check if workflow ran successfully in **Actions** tab
2. Clear browser cache
3. Wait a few minutes for GitHub Pages to update

---

**Problem**: 404 error on GitHub Pages

**Solution**:
1. Verify **Settings** → **Pages** source is set to `gh-pages` branch
2. Check that `site_url` in `mkdocs.yml` matches your GitHub Pages URL
3. Ensure the workflow completed successfully

### Build Errors

**Problem**: MkDocs build fails

**Solution**:
1. Test locally first: `mkdocs build --strict`
2. Fix any broken links or missing files
3. Check `mkdocs.yml` for syntax errors

### Custom Domain

To use a custom domain (e.g., `docs.truecash.app`):

1. Create `docs/CNAME` file:
   ```
   docs.truecash.app
   ```

2. Configure DNS:
   - Add CNAME record pointing to `satyakommula96.github.io`

3. Update `mkdocs.yml`:
   ```yaml
   site_url: https://docs.truecash.app/
   ```

4. In GitHub **Settings** → **Pages**, add custom domain

## 📋 Deployment Checklist

Before deploying:

- [ ] All documentation pages are complete
- [ ] Links are working (`mkdocs build --strict`)
- [ ] Images and assets are included
- [ ] Navigation structure is correct in `mkdocs.yml`
- [ ] GitHub Pages is enabled in repository settings
- [ ] Workflow permissions are set correctly

## 🔄 Workflow Details

### Triggers

The workflow runs when:
- Changes pushed to `main` branch affecting:
  - `docs/**` (any documentation file)
  - `mkdocs.yml` (configuration)
  - `.github/workflows/deploy-docs.yml` (workflow itself)
- Manually triggered via GitHub Actions UI

### Steps

1. **Checkout**: Fetches repository code
2. **Setup Python**: Installs Python 3.x
3. **Cache**: Caches pip packages for faster builds
4. **Install**: Installs MkDocs and plugins
5. **Build**: Builds documentation with `--strict` flag
6. **Deploy**: Pushes to `gh-pages` branch

### Build Time

Typical build time: **1-2 minutes**

### Caching

Dependencies are cached to speed up builds. Cache is invalidated when `requirements.txt` changes.

## 📊 Monitoring

### View Deployment History

1. Go to **Actions** tab
2. Filter by **Deploy Documentation** workflow
3. View all past deployments

### Analytics (Optional)

To add Google Analytics:

1. Get your GA tracking ID
2. Update `mkdocs.yml`:
   ```yaml
   extra:
     analytics:
       provider: google
       property: G-XXXXXXXXXX
   ```

## 🎯 Best Practices

1. **Test Locally**: Always run `mkdocs serve` before pushing
2. **Strict Mode**: Use `mkdocs build --strict` to catch errors
3. **Commit Messages**: Use conventional commits (e.g., `docs: update installation guide`)
4. **Review Changes**: Preview changes locally before deploying
5. **Incremental Updates**: Deploy small, frequent updates rather than large batches

## 📚 Resources

- [MkDocs Documentation](https://www.mkdocs.org/)
- [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/)
- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

---

**Your documentation is now set up for automatic deployment! 🎉**

Every push to `main` will automatically update your live documentation site.
