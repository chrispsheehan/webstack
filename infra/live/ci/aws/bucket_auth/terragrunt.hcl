include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  bucket_reference = "lambda-code-auth"
}

terraform {
  source = "../../../../modules/aws/bucket"
}
