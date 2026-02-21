# GitHub Setup & Upload Guide

## Step 1: Create GitHub Repository

### 1.1 Create on GitHub Website
1. Go to [GitHub.com](https://github.com)
2. Sign in to your account
3. Click **"+"** → **"New repository"**
4. Fill in:
   - **Repository name**: `wallet-api` (or your preferred name)
   - **Description**: "High-performance REST API for wallet management with optimistic locking"
   - **Visibility**: Public (unless you want Private)
   - **Initialize repository**: Leave unchecked (we have files already)
5. Click **"Create repository"**

### 1.2 Get Repository URL
- Copy the HTTPS URL: `https://github.com/YOUR_USERNAME/wallet-api.git`
- (or use SSH if configured: `git@github.com:YOUR_USERNAME/wallet-api.git`)

## Step 2: Initialize Git (Windows PowerShell/cmd)

### 2.1 Navigate to Project
```powershell
cd c:\Users\purni\Desktop\ass
```

### 2.2 Initialize Repository
```bash
git init
git add .
git commit -m "Initial commit: Complete wallet API implementation"
```

### 2.3 Set Default Branch
```bash
git branch -M main
```

### 2.4 Add Remote Repository
```bash
git remote add origin https://github.com/YOUR_USERNAME/wallet-api.git
```

Replace `YOUR_USERNAME` with your actual GitHub username.

### 2.5 Push to GitHub
```bash
git push -u origin main
```

You may be prompted for GitHub credentials. Enter your username and personal access token.

## Step 3: Verify Upload (Linux/macOS)

If running on Linux/macOS, same commands apply:

```bash
cd /path/to/wallet-api
git init
git add .
git commit -m "Initial commit: Complete wallet API implementation"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/wallet-api.git
git push -u origin main
```

## Step 4: GitHub Configuration (Optional But Recommended)

### 4.1 Add Branch Protection Rules
1. Go to repository → **Settings** → **Branches**
2. Add rule for `main` branch:
   - ✓ Require pull request reviews
   - ✓ Require status checks to pass
   - ✓ Require branches to be up to date

### 4.2 Enable GitHub Actions
1. Go to **Actions** tab
2. Workflows are already provided in `.github/workflows/build.yml`
3. Actions will run automatically on push/PR

### 4.3 Add Topics (Helps Discoverability)
1. Go to **Settings** → **General**
2. Add topics: `java`, `spring-boot`, `rest-api`, `wallet`, `docker`

## Step 5: Verify Installation

After pushing to GitHub, verify everything is there:

```bash
# Check remote configuration
git remote -v

# Verify all files are pushed
git log --oneline
git ls-tree -r HEAD | wc -l  # Count files
```

Or check on GitHub website:
1. Visit your repository: `https://github.com/YOUR_USERNAME/wallet-api`
2. Verify all files appear in the file listing
3. Check that README.md displays properly

## Troubleshooting

### Error: "fatal: not a git repository"
```bash
# Navigate to project directory first
cd path/to/wallet-api
git init
```

### Error: "fatal: remote origin already exists"
```bash
# Update existing remote
git remote set-url origin https://github.com/YOUR_USERNAME/wallet-api.git
```

### Error: "403 Forbidden"
- Verify GitHub credentials are correct
- Generate personal access token if using HTTPS:
  1. GitHub → Settings → Developer settings → Personal access tokens
  2. Generate new token with `repo` scope
  3. Use token as password when pushing

### Error: "Please tell me who you are"
```bash
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
```

### Error: ".gitignore is not working"
```bash
# Remove cached files and re-add
git rm -r --cached .
git add .
git commit -m "Apply gitignore rules"
git push
```

## After Upload

### Add to CI/CD
GitHub Actions workflow is already configured in `.github/workflows/build.yml`

To enable:
1. Go to **Actions** tab
2. Click on **build.yml** workflow
3. It will run automatically on next push

### Create Issues
1. Go to **Issues** tab
2. Use templates in `.github/ISSUE_TEMPLATE/`
3. Report bugs or request features

### Create Pull Requests
1. Create feature branch: `git checkout -b feature/my-feature`
2. Make changes and commit
3. Push: `git push origin feature/my-feature`
4. Create PR on GitHub
5. Use template from `.github/pull_request_template.md`

## Cloning for Development

Once on GitHub, others can clone with:

```bash
# HTTPS
git clone https://github.com/YOUR_USERNAME/wallet-api.git
cd wallet-api

# SSH (if configured)
git clone git@github.com:YOUR_USERNAME/wallet-api.git
cd wallet-api

# Setup and run
mvn clean package -DskipTests
docker-compose up -d
```

## GitHub Pages (Optional)

To host documentation on GitHub Pages:

1. Go to **Settings** → **Pages**
2. Select **Source**: `main` branch, `/root` folder
3. GitHub will build and serve documentation

Documentation files will be available at:
- `https://YOUR_USERNAME.github.io/wallet-api/`

## Release & Tags (Future)

When ready to release:

```bash
# Create version tag
git tag -a v1.0.0 -m "Initial release"

# Push tag
git push origin v1.0.0

# Create release on GitHub
# Go to Releases → Draft a new release
# Select tag v1.0.0 and add release notes
```

## Collaborators

To add collaborators:

1. Go to **Settings** → **Collaborators**
2. Click "Add people"
3. Enter GitHub username
4. Select permission level

## Repository Statistics

After upload, GitHub will show:

- Code frequency graph
- Commit history
- Network visualization
- Contributors
- Languages used

## Final Checklist

- [ ] Repository created on GitHub
- [ ] Local git initialized
- [ ] Files committed and pushed
- [ ] README.md displays correctly
- [ ] All files visible on GitHub
- [ ] GitHub Actions configured
- [ ] Branch protection rules added (optional)
- [ ] Documentation link works
- [ ] Clone and build verification

## Share Your Repository

Once uploaded:

1. **Copy link**: `https://github.com/YOUR_USERNAME/wallet-api`
2. **Share in ReadMe**: Add to portfolio or job applications
3. **Social Share**: Share on LinkedIn, Twitter, etc.

## Example Commands Recap

```bash
# Complete workflow
cd c:\Users\purni\Desktop\ass

git init
git add .
git commit -m "Initial commit: Complete wallet API implementation"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/wallet-api.git
git push -u origin main

# Verify
git log --oneline
git remote -v
```

---

**That's it!** Your Wallet API is now on GitHub and ready to share! 🎉

For more information, visit [GitHub Docs](https://docs.github.com).
