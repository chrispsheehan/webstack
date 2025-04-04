include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  bucket_reference = "api-lambda-code"
}

terraform {
  source = "../../../../modules/aws/bucket"
}
