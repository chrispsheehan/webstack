include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "tfr:///chrispsheehan/github-oidc-role/aws?version=0.0.4"
}
