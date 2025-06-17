variable "github_repo" {
  description = "Name of a the github repo"
  type        = string
}

variable "default_branch" {
  description = "Name of default branch to be protected and merged into"
  type        = string
}

variable "is_public" {
  description = "Repo is public (true) or private (false)"
  type        = bool
  default     = true
}
