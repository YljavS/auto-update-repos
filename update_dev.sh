#!/bin/bash
set -euo pipefail

# Usage: ./update_repo.sh <repo_url>
repo="$1"

echo "Updating repository: $repo"
repo_dir=$(basename "$repo" .git)

branch_name="auto-update-git-script-ylja"

if [ -d "$repo_dir" ]; then
  echo "Directory '$repo_dir' already exists, skipping clone"
else
  git clone "$repo"
fi

cd "$repo_dir"
echo "Entered directory: $repo_dir"

base_branch=""
for branch in develop development; do
  if git ls-remote --heads origin "$branch" | grep -q "$branch"; then
    base_branch="$branch"
    break
  fi
done

if [ -z "$base_branch" ]; then
  echo "No base branch found, defaulting to main"
  base_branch="main"
fi
echo "Using base branch: $base_branch"

git checkout "$base_branch"

# Kijk local en remote of de branch bestaat en remove.
git branch -D "$branch_name" 2>/dev/null || true
if git ls-remote --exit-code --heads origin "$branch_name" &>/dev/null; then
  git push origin --delete "$branch_name" || echo "Failed to delete remote branch or branch does not exist"
fi

git checkout -b "$branch_name"

echo "Running poetry install and update..."
poetry install
poetry update

git commit -asm "auto update dependencies" || echo "No changes to commit"
git push --set-upstream origin "$branch_name"

gh pr create --fill --base "$base_branch" --head "$branch_name" || echo "Failed to create PR or already exists"
