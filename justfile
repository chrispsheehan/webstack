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
    just temp-init


format:    
    #!/usr/bin/env bash
    terraform fmt -recursive
    terragrunt hclfmt
    npm run format --prefix frontend


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
    export GITHUB_TOKEN=$(just get-git-token)
    just tg {{env}} aws/oidc apply
    just tg {{env}} github/environment apply


temp-init:
    #!/usr/bin/env bash
    export GITHUB_TOKEN=$(just get-git-token)
    export TEMP_DEPLOY_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    just tg dev github/environment apply


import-repo-warning:
    @echo -e "\033[1;33mWARNING: Setting up github repo - this is a one time action - sure?\033[0m\n" >&2
    @printf "\033[1;32mPress any key to proceed or Ctrl+C to abort: \033[0m"
    @read -n 1 -s response || exit 1

import-repo:
    #!/usr/bin/env bash
    just import-repo-warning || exit 1
    export GITHUB_TOKEN=$(just get-git-token)   
    repo_name=$(just get-git-repo)
    just tg ci github/repo init
    just tg ci github/repo "import github_repository.this $repo_name"
    just tg ci github/repo "import github_actions_repository_permissions.this $repo_name"


setup-repo:
    #!/usr/bin/env bash
    export GITHUB_TOKEN=$(just get-git-token)
    just tg ci github/repo apply
    just init ci


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


frontend-upload:
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ -z "$BUCKET_NAME" ]]; then
        echo "Error: BUCKET_NAME environment variable is not set."
        exit 1
    fi
    aws s3 sync {{justfile_directory()}}/frontend/dist "s3://$BUCKET_NAME/" --storage-class STANDARD


frontend-build:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🔄 Cleaning previous builds..."
    rm -rf frontend/dist
    echo "📦 Building frontend..."
    npm install --prefix frontend
    npm run build --prefix frontend


backend-upload:
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ -z "$BUCKET_NAME" ]]; then
        echo "Error: BUCKET_NAME environment variable is not set."
        exit 1
    fi
    if [[ -z "$ZIP_NAME" ]]; then
        echo "Error: ZIP_NAME environment variable is not set."
        exit 1
    fi
    aws s3 cp "backend/$ZIP_NAME.zip" "s3://$BUCKET_NAME/" --storage-class STANDARD


backend-build:
    #!/usr/bin/env bash
    set -euo pipefail

    python3 -m venv venv
    source venv/bin/activate

    echo "🔄 Cleaning previous builds..."
    rm -f backend/api.zip backend/auth.zip
    rm -rf backend/build/

    echo "📦 Building auth Lambda..."
    mkdir -p backend/build/auth
    pip install --target backend/build/auth -r backend/auth/requirements.txt
    cp backend/auth/*.py backend/build/auth/
    cd backend/build/auth
    zip -r ../../auth.zip . > /dev/null
    cd ../../../

    echo "📦 Building api Lambda..."
    mkdir -p backend/build/api
    pip install --target backend/build/api -r backend/api/requirements.txt
    cp backend/api/*.py backend/build/api/
    cd backend/build/api
    zip -r ../../api.zip . > /dev/null
    cd ../../../

    echo "✅ Done: backend/api.zip and backend/auth.zip"


start:
    #!/usr/bin/env bash
    npm i
    npm run dev