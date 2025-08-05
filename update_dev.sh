#!/bin/bash
set -euo pipefail

# Usage: ./update_repo.sh <repo_url>
repo="$1"

echo -e "\033[1;34m🔄 Updating repository: $repo\033[0m"
repo_dir=$(basename "$repo" .git)

branch_name="auto-update-git-script-ylja"

if [ -d "$repo_dir" ]; then
  echo -e "\033[1;33m📂 Directory '$repo_dir' already exists, skipping clone\033[0m"
else
  git clone "$repo"
fi

cd "$repo_dir"
echo -e "\033[1;34m📁 Entered directory: $repo_dir\033[0m"

base_branch=""
for branch in develop development; do
  if git ls-remote --heads origin "$branch" | grep -q "$branch"; then
    base_branch="$branch"
    break
  fi
done

if [ -z "$base_branch" ]; then
  echo -e "\033[1;31m⚠️ No base branch found, defaulting to main\033[0m"
  base_branch="main"
fi
echo -e "\033[1;34m🌿 Using base branch: $base_branch\033[0m"

git checkout "$base_branch"

# Kijk local en remote of de branch bestaat en remove.
git branch -D "$branch_name" 2>/dev/null || true
if git ls-remote --exit-code --heads origin "$branch_name" &>/dev/null; then
  git push origin --delete "$branch_name" || echo -e "\033[1;31m🧨 Failed to delete remote branch or branch does not exist\033[0m"
fi

git checkout -b "$branch_name"

echo -e "\033[1;36m📦 Running poetry install and update...\033[0m"
# poetry install

echo -e "\033[1;33m🔧 Running poetry update and capturing changes...\033[0m"
# Capture the output of poetry update
update_output=$(poetry update 2>&1)

# Extract the lines about updated packages
summary=$(echo "$update_output" | grep -E '^\s*- Updating')

if [ -z "$summary" ]; then
  summary="No dependency updates detected."
fi

# ✅ Show summary to test
echo -e "\033[1;36m📋 Summary of updated packages:\033[0m"
echo -e "\033[0;33m$summary\033[0m"

git commit -asm "auto update dependencies" || echo -e "\033[1;33m✅ No changes to commit\033[0m"
git push --set-upstream origin "$branch_name"

echo -e "\033[1;33m📤 Creating pull request with summary of updates\033[0m"
gh pr create \
  --title "Auto update dependencies" \
  --body "This PR was created automatically to update Poetry dependencies.

**📋 Summary of updated packages:**

\`\`\`diff
$summary
\`\`\`
" \
  --base "$base_branch" \
  --head "$branch_name" || echo "Failed to create PR or already exists"