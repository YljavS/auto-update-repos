# Automated Dependency Updates with GitHub Actions

This GitHub Action workflow automatically updates Poetry dependencies across multiple repositories using the `github-actions[bot]` identity.

## 🚀 Features

- **Automated Scheduling**: Runs every Monday at 9:00 AM UTC
- **Manual Triggering**: Can be triggered manually via GitHub UI
- **Multiple Repository Support**: Processes multiple repos in parallel
- **Clear Logging**: Detailed step-by-step output in GitHub Actions
- **Bot Identity**: Uses `github-actions[bot]` for commits and PRs
- **Smart Branch Detection**: Automatically finds develop/development/main branch
- **Comprehensive PR Details**: Includes diff summary and workflow links

## 📋 Setup Requirements

### 1. Personal Access Token (PAT)

Create a Personal Access Token and add it as a repository secret:

1. Go to GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Set expiration (recommend 1 year)
4. Select scopes:
   - ✅ `repo` (Full control of private repositories)
   - ✅ `workflow` (Update GitHub Action workflows)
5. Generate token and copy it

6. In your automation repository:
   - Go to Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Name: `PERSONAL_ACCESS_TOKEN`
   - Value: Your Personal Access Token

### 2. Repository Configuration

Edit the `matrix.repository` section in `.github/workflows/update-dependencies.yml`:

```yaml
strategy:
  matrix:
    repository: 
      - "https://github.com/YourOrg/repo1.git"
      - "https://github.com/YourOrg/repo2.git"
      # Add more repositories here
```

## 🔧 How It Works

### Workflow Steps

1. **🔧 Checkout**: Checks out this automation repository
2. ** Install Poetry**: Sets up Poetry for dependency management
3. **⚙️ Configure Git**: Sets up github-actions[bot] identity
4. **📊 Extract Info**: Gets repository name and generates branch name
5. **🔄 Clone Repository**: Clones the target repository with PAT authentication
6. **🐍 Detect Python Version**: Reads Python version from pyproject.toml
7. **🐍 Setup Python**: Installs the correct Python version for the project
8. **🌿 Determine Base Branch**: Finds develop/development/main branch
9. **🔗 Configure Git Remote**: Sets up authenticated git remote for pushes
10. **🧹 Clean Up**: Removes existing automation branches
11. **🆕 Create Branch**: Creates new update branch
12. **📦 Install Dependencies**: Runs `poetry install`
13. **🔄 Update Dependencies**: Runs `poetry update` and captures changes
14. **📝 Commit Changes**: Commits updates if any found
15. **🔀 Create Pull Request**: Creates PR with detailed summary
16. **🧹 Cleanup**: Removes cloned repository

### Branch Naming

Branches are named: `auto-update-dependencies-YYYYMMDD`

### PR Content

Each PR includes:
- 🤖 Clear automated indicator
- 📋 Diff summary of updated packages
- 🔍 Workflow run link
- ✅ Update timestamp
- 🏷️ Automated labels

## 📊 Output & Monitoring

### GitHub Actions Logs

The workflow provides detailed, grouped logs for each step:

- **Repository Processing**: Shows which repo is being updated
- **Branch Operations**: Displays branch creation/cleanup
- **Dependency Updates**: Lists all package changes
- **PR Creation**: Confirms successful PR creation
- **Summary**: Overview of all operations

### Step Outputs

Each major step outputs key information:
- Repository name and URL
- Base branch detected
- Whether updates were found
- Whether changes were committed
- PR creation status

## 🎯 Manual Triggering

You can manually trigger the workflow:

1. Go to Actions tab in your repository
2. Select "Auto Update Dependencies" workflow
3. Click "Run workflow"
4. Optionally specify specific repositories (comma-separated URLs)

## 🔍 Troubleshooting

### Common Issues

1. **SSH Authentication Failed**
   - Verify `SSH_PRIVATE_KEY` secret is correctly set
   - Ensure the public key is added to target repositories

2. **No pyproject.toml Found**
   - Workflow will skip Poetry operations and log this
   - Only applies to repositories without Poetry

3. **PR Creation Failed**
   - May indicate PR already exists
   - Check target repository for existing automation PRs

4. **Permission Denied**
   - Verify the SSH key has write access to target repositories
   - Check repository settings allow Actions to create PRs

### Debug Mode

Add this to any step for more verbose output:
```yaml
env:
  ACTIONS_STEP_DEBUG: true
```

## 🔄 Migration from Bash Script

This workflow replaces:
- `update_all_repos.py` → Matrix strategy in GitHub Actions
- `update_dev.sh` → Individual workflow steps
- `local_config.py` → Repository list in workflow file

Key improvements:
- ✅ Uses github-actions[bot] identity
- ✅ Parallel processing of repositories
- ✅ Better error handling and logging
- ✅ No local environment dependencies
- ✅ Integrated with GitHub ecosystem

## 📅 Schedule

Currently runs every Monday at 9:00 AM UTC. To change:

```yaml
schedule:
  - cron: '0 9 * * 1'  # Minute Hour Day Month DayOfWeek
```

Examples:
- Daily at 2 AM: `'0 2 * * *'`
- Every Friday at 5 PM: `'0 17 * * 5'`
- First day of month: `'0 9 1 * *'`