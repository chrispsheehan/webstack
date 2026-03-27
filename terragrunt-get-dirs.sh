#!/bin/bash
# Outputs all directories containing terragrunt.hcl excluding .terragrunt-cache dirs as space-separated string

dirs=$(find . -type d -name ".terragrunt-cache" -prune -o -type f -name "terragrunt.hcl" -print | xargs -n1 dirname | sort -u)

# convert newline to space (if any)
echo "$dirs" | tr '\n' ' '
