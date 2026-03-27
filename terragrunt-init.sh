find . -type d -name ".terragrunt-cache" -prune -o -type f -name "terragrunt.hcl" -print \
| xargs -n1 dirname \
| sort -u \
| while read -r dir; do
  echo "🔹 Initializing in $dir..."
  (cd "$dir" && terragrunt init -backend=false)
done