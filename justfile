_default:
    just --list


get-git-token:
    #!/usr/bin/env bash
    if ! gh auth status &> /dev/null; then
        gh auth login
    fi
    GITHUB_TOKEN=$(gh auth token 2>/dev/null)
    echo $GITHUB_TOKEN


get-git-repo:
    #!/usr/bin/env bash
    repo_basename=$(basename $(git remote get-url origin))
    echo "${repo_basename%%.*}"


branch name:
    #!/usr/bin/env bash
    git checkout main
    git fetch && git pull
    git branch {{ name }} && git checkout {{ name }}


format:    
    #!/usr/bin/env bash
    terraform fmt -recursive
    terragrunt hclfmt


validate:
    #!/usr/bin/env bash
    for dir in terraform_modules/*; do
        if [ -d "$dir" ] && [[ $(basename "$dir") != '!'* ]]; then
            folder_name=$(basename "$dir")
            echo "Validating $folder_name"
            just tg "$folder_name" init
            just tg "$folder_name" validate
        fi
    done


# Terragrunt operation on {{module}} containing terragrunt.hcl
tg env module op:
    #!/usr/bin/env bash
    cd {{justfile_directory()}}/infra/live/{{env}}/{{module}} ; terragrunt {{op}}


tg-all op:
    #!/usr/bin/env bash
    cd {{justfile_directory()}}/infra/live 
    terragrunt run-all {{op}}


init env:
    #!/usr/bin/env bash
    export TF_VAR_git_token=$(just get-git-token)
    just tg {{env}} aws/oidc apply
    just tg {{env}} github/environment apply


import-repo:
    #!/usr/bin/env bash
    export TF_VAR_git_token=$(just get-git-token)   
    repo_name=$(just get-git-repo)
    just tg ci github/repo init
    just tg ci github/repo "import github_repository.this $repo_name"


setup-repo:
    #!/usr/bin/env bash
    export TF_VAR_git_token=$(just get-git-token)
    just tg ci github/repo apply


PROJECT_DIR := justfile_directory()

clean-terragrunt-cache:
    @echo "Cleaning up .terraform directories in {{PROJECT_DIR}}..."
    find {{PROJECT_DIR}} -type d -name ".terraform" -exec rm -rf {} +
    @echo "Cleaning up .terraform.lock.hcl files in {{PROJECT_DIR}}..."
    find {{PROJECT_DIR}} -type f -name ".terraform.lock.hcl" -exec rm -f {} +
    @echo "Cleaning up .terragrunt-cache directories in {{PROJECT_DIR}}..."
    find {{PROJECT_DIR}} -type d -name ".terragrunt-cache" -exec rm -rf {} +
    @echo "Cleaning up terragrunt-debug.tfvars.json files in {{PROJECT_DIR}}..."
    find {{PROJECT_DIR}} -type f -name "terragrunt-debug.tfvars.json" -exec rm -f {} +
