include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../modules/aws/code_buckets"
}
