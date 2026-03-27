#!/bin/sh
set -eu

any_diffs=0

dirs=$(find . -type d -name ".terragrunt-cache" -prune -o -type f -name "terragrunt.hcl" -print | xargs -n1 dirname | sort -u)

for dir in $dirs; do
  echo "Checking git changes in $dir..."

  unstaged=$(git diff --relative="$dir" -- "$dir")
  untracked=$(git ls-files --others --exclude-standard -- "$dir")

  if [ -n "$unstaged" ] || [ -n "$untracked" ]; then
    echo "❗ Changes found in $dir:"

    if [ -n "$unstaged" ]; then
      echo "Unstaged changes:"
      echo "$unstaged"
    fi

    if [ -n "$untracked" ]; then
      echo "Untracked files:"
      echo "$untracked"
    fi

    any_diffs=1
  else
    echo "✅ No changes in $dir"
  fi

  echo "----------------------------------------"
done

if [ "$any_diffs" -eq 1 ]; then
  echo "Some changes found! Exiting with failure."
  exit 1
else
  echo "No changes detected anywhere. All good."
  exit 0
fi
