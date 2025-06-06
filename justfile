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

lambda-invoke:
    #!/bin/bash
    OUTPUT_FILE=output.json
    rm -f $OUTPUT_FILE
    RESPONSE=$(aws lambda invoke --function-name $LAMBDA_NAME --region $AWS_REGION --payload "$PAYLOAD" $OUTPUT_FILE)
    LAMBDA_RETURN_CODE=$(jq -r '.StatusCode' <<< "$RESPONSE")
    if [ "$LAMBDA_RETURN_CODE" -eq 200 ]; then
        echo "Lambda function invoked successfully."
    else
        echo "Lambda function failed with return code: $LAMBDA_RETURN_CODE"
    fi
    cat $OUTPUT_FILE
    LAMBDA_STATUS_CODE=$(jq -r '.statusCode // empty' "$OUTPUT_FILE")

    if [ "$LAMBDA_STATUS_CODE" = "200" ]; then
        echo "✅ Lambda function completed successfully."
        exit 0
    else
        echo "❌ Lambda function failed or returned non-200 status code: $LAMBDA_STATUS_CODE"
        exit 1
    fi


get-initial-deploy-var:
  #!/usr/bin/env bash
  set -euo pipefail

  TAG_KEY="Project"
  TAG_VALUE=${GITHUB_REPOSITORY//\//-}
  ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
  DISTRIBUTION_IDS=$(aws cloudfront list-distributions --query "DistributionList.Items[].Id" --output text)
  INITIAL_DEPLOY=true

  for ID in $DISTRIBUTION_IDS; do
    ARN="arn:aws:cloudfront::${ACCOUNT_ID}:distribution/${ID}"

    TAG_MATCH=$(aws cloudfront list-tags-for-resource --resource "$ARN" \
      --query "Tags.Items[?Key=='${TAG_KEY}' && Value=='${TAG_VALUE}']" \
      --output json)

    if [[ "$TAG_MATCH" != "[]" ]]; then
      INITIAL_DEPLOY=false
    fi
  done
  echo "$INITIAL_DEPLOY"


git-tidy:
    #!/usr/bin/env bash
    git fetch --prune
    for branch in $(git branch -vv | grep ': gone]' | awk '{print $1}'); do
        git branch -d $branch
    done


branch name:
    #!/usr/bin/env bash
    git fetch origin
    git checkout main
    git branch --set-upstream-to=origin/main {{ name }}
    git pull
    git checkout -b {{ name }}
    git push -u origin {{ name }}


format:    
    #!/usr/bin/env bash
    terraform fmt -recursive
    terragrunt hclfmt
    npm run format --prefix frontend
    prettier --no-config --write ".github/**/*.y?(a)ml"


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
    just tg ci aws/oidc apply
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


check-version:
    #!/usr/bin/env bash
    set -euo pipefail

    FULL_BUCKET_NAME="$BUCKET_NAME/$VERSION/"

    if ! aws s3api head-bucket --bucket "$BUCKET_NAME" >/dev/null 2>&1; then
        echo "❌ The bucket '$BUCKET_NAME' does not exist or is inaccessible."
        exit 1
    fi

    if ! aws s3 ls "$FULL_BUCKET_NAME" >/dev/null 2>&1; then
        echo "❌ The subpath '$VERSION' does not exist in bucket '$BUCKET_NAME'."
        exit 1
    fi

    FILES=$(aws s3 ls $FULL_BUCKET_NAME --recursive | wc -l | xargs)
    if [ -n "$FILES" ]; then
        echo "✅ $FILES file(s) found in $FULL_BUCKET_NAME"
    else
        echo "❌ No files found under $FULL_BUCKET_NAME"
        exit 1
    fi


frontend-upload:
    #!/usr/bin/env bash
    set -euo pipefail
    aws s3 sync {{justfile_directory()}}/frontend/dist "s3://$BUCKET_NAME/$VERSION/" --storage-class STANDARD


frontend-refresh:
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ -z "$DISTRIBUTION_ID" ]]; then
        echo "Error: VERSION environment variable is not set."
        exit 1
    fi

    MAX_ATTEMPTS=18
    SLEEP_INTERVAL=10

    echo "🔄 Creating CloudFront invalidation..."
    INVALIDATION_ID=$(aws cloudfront create-invalidation \
        --distribution-id "$DISTRIBUTION_ID" \
        --paths "/*" \
        --query 'Invalidation.Id' \
        --output text)

    for ((i=1; i<=MAX_ATTEMPTS; i++)); do
    STATUS=$(aws cloudfront get-invalidation \
        --distribution-id "$DISTRIBUTION_ID" \
        --id "$INVALIDATION_ID" \
        --query 'Invalidation.Status' \
        --output text)

    echo "Attempt $i: Invalidation status is $STATUS"

    if [[ "$STATUS" == "Completed" ]]; then
        echo "✅ Invalidation $INVALIDATION_ID completed successfully."
        exit 0
    fi

    sleep "$SLEEP_INTERVAL"
    done

    echo "❌ Invalidation $INVALIDATION_ID did not complete within expected time."
    exit 1


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

    BACKEND_DIR="{{justfile_directory()}}/backend"

    echo "📤 Uploading .zip files from $BACKEND_DIR to s3://$BUCKET_NAME/$VERSION/"

    aws s3 cp "$BACKEND_DIR" "s3://$BUCKET_NAME/$VERSION/" \
        --recursive \
        --exclude "*" \
        --include "*.zip" \
        --storage-class STANDARD


backend-build:
    #!/usr/bin/env bash
    set -euo pipefail

    python3 -m venv venv
    source venv/bin/activate

    BACKEND_DIR="{{justfile_directory()}}/backend"
    BACKEND_BUILD_DIR="$BACKEND_DIR/build"

    echo "🔄 Cleaning previous builds..."
    rm -rf $BACKEND_BUILD_DIR

    for dir in $(find "$BACKEND_DIR" -mindepth 1 -maxdepth 1 -type d); do
        app_name=$(basename "$dir")
        echo "📦 Building $app_name Lambda..."
        mkdir -p "$BACKEND_BUILD_DIR/$app_name"
        pip install --target "$BACKEND_BUILD_DIR/$app_name" -r "$dir/requirements.txt"
        cp "$dir"/*.py "$BACKEND_BUILD_DIR/$app_name/"
        (
            cd "$BACKEND_BUILD_DIR/$app_name"
            zip -r "../../$app_name.zip" . > /dev/null
        )
        echo "✅ Done: backend/$app_name.zip"
    done

seed:
    #!/usr/bin/env bash
    set -e

    RED='\033[0;31m'
    NC='\033[0m' # No Color

    echo -e "${RED}⚠️  WARNING: This operation will call the AWS Cost Explorer API and may incur charges beyond the free tier.${NC}"
    read -p "Do you want to continue? (y/n): " confirm
    if [[ "$confirm" != "y" ]]; then
      echo "❌ Aborted."
      exit 1
    fi

    python3 -m venv venv
    source venv/bin/activate
    pip install python-dotenv boto3
    export ENVIRONMENT_NAME=prod
    export PROJECT_NAME=chrispsheehan-webstack 
    export PUBLIC_DIR=${PWD}/frontend/public 
    python backend/local_runner.py


start:
    #!/usr/bin/env bash
    npm i --prefix frontend
    docker compose up -d
    docker compose logs -f &
    npm run dev --prefix frontend


run-log-proc:
    #!/usr/bin/env bash
    python3 -m venv venv
    source venv/bin/activate
    pip install python-dotenv boto3
    export S3_LOGS_BUCKET=chrispsheehan.com.logs
    export LOG_PROCESSOR_OUT=${PWD}/tmp
    python backend/temp.py