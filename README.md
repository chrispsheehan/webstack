# webstack

Full stack web project.

## setup

**One time** setup with `just import-repo` to import the repo into the terraform state.

Apply github settings and create github `ci` environment seeded with required variables and branch controls.

```sh
just setup-repo
just init dev
judt init prod
```

Example plan command - `just tg ci aws/bucket_auth plan`

**_WARNING_**
Terragrunt will create the s3 state bucket the first time this is done - this should only happen _ONCE_.

```sh
Remote state S3 bucket your-state-bucket-name-tfstate does not exist or you dont have permissions to access it. Would you like Terragrunt to create it? (y/n) y
```

#### required installs

```sh
brew install terragrunt
brew install terraform
brew install just
brew install awscli
brew install gh
brew install node
npm install -g prettier
```

## deploy from temp branch

- run `just temp-init` to allow deploys from branch
- trigger workflow from your branch in `.github/workflows`

## 🧞 Commands

All commands are run from the root of the project, from a terminal:

| Command                   | Action                                           |
| :------------------------ | :----------------------------------------------- |
| `npm install`             | Installs dependencies                            |
| `npm run dev`             | Starts local dev server at `localhost:4321`      |
| `npm run build`           | Build your production site to `./dist/`          |
| `npm run preview`         | Preview your build locally, before deploying     |
| `npm run astro ...`       | Run CLI commands like `astro add`, `astro check` |
| `npm run astro -- --help` | Get help using the Astro CLI                     |

## 👀 Want to learn more?

Feel free to check [our documentation](https://docs.astro.build) or jump into our [Discord server](https://astro.build/chat).

