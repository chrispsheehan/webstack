include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  bucket_reference = "static-web"
}

terraform {
  source = "../../../../modules/aws/bucket"
}
