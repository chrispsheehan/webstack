resource "github_branch_protection" "main" {
  repository_id       = data.github_repository.this.node_id
  pattern             = var.default_branch
  allows_force_pushes = false

  required_pull_request_reviews {
    dismiss_stale_reviews = true
  }
}
