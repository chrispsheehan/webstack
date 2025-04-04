include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  bucket_reference = "lambda-code-api"
}

terraform {
  source = "../../../../modules/aws/bucket"
}
