# webstack

Full stack web project.

---

## setup

**One time** setup with `just import-repo` to import the repo into the Terraform state.

Apply GitHub settings and create the GitHub `ci` environment seeded with required variables and branch controls.

```sh
just setup-repo
just init dev
just init prod
```

Example plan command:

```sh
just tg dev aws/jobs plan
```

**_WARNING_**  
Terragrunt will create the S3 state bucket the first time this is done — this should only happen **once**:

```
Remote state S3 bucket your-state-bucket-name-tfstate does not exist or you don't have permissions to access it. Would you like Terragrunt to create it? (y/n) y
```

---

## ☁️ AWS OIDC Integration

This project uses **GitHub OIDC (OpenID Connect)** for secure, keyless access to AWS.

### 🔐 Terraform OIDC Role Module

The Terraform module [`chrispsheehan/github-oidc-role/aws`](https://registry.terraform.io/modules/chrispsheehan/github-oidc-role/aws/latest) is used to:

- Create an IAM role with the correct trust relationship
- Grant least-privilege access for GitHub Actions
- Bind to a GitHub repository and environment

---

### 🤖 GitHub Actions

#### 1. [`chrispsheehan/just-aws-oidc-action@0.1.1`](https://github.com/chrispsheehan/just-aws-oidc-action)

This action sets up AWS OIDC and runs a `just` command with AWS credentials:

```yaml
- uses: chrispsheehan/just-aws-oidc-action@0.1.1
  with:
    aws_oidc_role_arn: arn:aws:iam::123456789012:role/webstack-ci
    just_command: seed dev
```

#### 2. [`chrispsheehan/terragrunt-aws-oidc-action@0.3.0`](https://github.com/chrispsheehan/terragrunt-aws-oidc-action)

This action:

- Authenticates via OIDC
- Installs Terraform and Terragrunt
- Runs a Terragrunt command with injected config

```yaml
- uses: chrispsheehan/terragrunt-aws-oidc-action@0.3.0
  with:
    aws_oidc_role_arn: arn:aws:iam::123456789012:role/webstack-ci
    tg_directory: infrastructure/dev
    tg_action: apply
    override_tg_vars: '{"env": "dev"}'
```

---

## required installs

```sh
brew install terragrunt
brew install terraform
brew install just
brew install awscli
brew install gh
brew install node
npm install -g prettier
```

---

## scripts

- `just setup-repo` – apply GitHub repo state as per Terraform code  
- `just seed` – locally populate `frontend/public/data` with `data.json` files  
- `just start` – open hot-reloaded website  
- `just temp-init` – allow current branch to deploy from `dev` GitHub environment  

---

## infrastructure

![Infrastructure](docs/infra.png)
