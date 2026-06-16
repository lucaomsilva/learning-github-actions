# GitHub Actions Workflow Documentation

This document serves as a study guide and reference for the concepts, actions, and variables utilized in the `.github/workflows/ci.yml` and `.github/workflows/cd.yml` pipelines.

## 1. Triggers (`on:`)
Triggers define *when* a workflow should execute. We used a mix of automated and manual triggers:
- **`push` and `pull_request`**: Runs whenever code is pushed to specific `branches` (like `main` or `develop`).
- **`tags`**: By adding `- 'v*'` under the `push` section, the workflow is configured to run when a new Git tag (like `v1.0.0`) is pushed to the repository.
- **`workflow_dispatch`**: Adds a "Run workflow" button in the Actions tab on the GitHub GUI, allowing manual execution. This works only when `workflow_dispatch` is in main branch.
- **`workflow_call`**: Transforms a workflow (like our `cd.yml`) into a **Reusable Workflow**. It cannot run by itself; it waits to be called by another workflow (like our `ci.yml`).

## 2. Uses of Actions (`uses:`)
GitHub Actions rely heavily on modular, pre-built steps called "actions":
- `actions/checkout@v4`: Clones the repository code into the virtual runner so your scripts can access it.
- `docker/setup-buildx-action@v3`: Prepares Docker Buildx, enabling advanced multi-stage builds and remote caching.
- `docker/login-action@v3`: Authenticates the runner to a container registry (like GHCR) so it has permission to push/pull images.
- `docker/build-push-action@v5`: Automates the `docker build` and `docker push` commands.
- `actions/upload-artifact@v4`: Zips and uploads files (like our compiled binary `app`) to GitHub's internal storage, allowing you to download them from the GUI or pass them between jobs.
- `actions/download-artifact@v4`: Retrieves artifacts that were uploaded by a previous job.
- `softprops/action-gh-release@v2`: Automates the creation of a GitHub Release on the GUI and attaches the binary to it.

## 3. GitHub Context Variables (`github.*`)
These variables hold dynamic metadata about the event that triggered the workflow:
- `${{ github.repository }}`: The name of the repository (e.g., `lucaomsilva/learning-github-actions`).
- `${{ github.actor }}`: The username of the person who triggered the workflow.
- `${{ github.ref }}`: The full Git reference path (e.g., `refs/tags/v1.0.0` or `refs/heads/main`).
- `${{ github.ref_name }}`: The short name of the branch or tag (e.g., `v1.0.0` or `main`).
- `${{ github.run_id }}`: A completely unique number for the current workflow run. We used this to tag temporary Docker containers (`build-env-${{ github.run_id }}`) so multiple workflows don't collide if they run at the same time.

## 4. Environment Variables (`GITHUB_*`)
GitHub provides special environment file commands that allow steps to communicate:
- `$GITHUB_ENV`: A temporary file. If you write `VERSION=1.0 >> $GITHUB_ENV`, GitHub exposes `$VERSION` as a standard bash environment variable to all *subsequent steps in the same job*.
- `$GITHUB_OUTPUT`: A temporary file used to pass variables to entirely *different jobs*. Must be referenced using the syntax `${{ steps.step_id.outputs.var_name }}`.
- `$GITHUB_SHA`: Contains the exact, long commit hash that triggered the workflow. We sliced it (`${GITHUB_SHA::7}`) to get a short, readable version.

## 5. Secrets and Tokens (`secrets.*`)
- **`${{ secrets.GITHUB_TOKEN }}`**: This is an automatically generated, temporary authentication token provided by GitHub on every run. We used it to securely log into the GitHub Container Registry and to grant the Release Action permission to create a release.
- **Custom Secrets**: If you have personal API keys or server passwords, you store them in GitHub Settings -> Secrets, and access them using `${{ secrets.MY_PASSWORD }}`. GitHub will mask them as `***` in the logs to prevent leaks.

## 6. Permissions and Restricted Words
By default, workflows have basic permissions. If you set `permissions: {}` at the top of your file, you intentionally strip the workflow of *all* permissions. 
Consequently, if a specific job needs to interact with GitHub, you must explicitly declare restricted words:
- `contents: read`: Allowed to clone the code.
- `contents: write`: Allowed to create tags, modify code, or create GitHub Releases (Required by `cd.yml`).
- `packages: write`: Allowed to push Docker images to the GitHub Container Registry (Required by `ci.yml`).

## 7. How GHCR (GitHub Container Registry) Works
GHCR is a Docker registry tightly integrated with GitHub, living at `ghcr.io`. 
1. **Authentication**: We log in using our GitHub username and the built-in `GITHUB_TOKEN`.
2. **Naming**: Images are tagged following a strict path format: `ghcr.io/username/repository/image-name:tag`.
3. **Caching**: GHCR allows us to push `buildcache` layers directly to the registry. When the workflow runs the next day, it pulls the cache from GHCR instead of rebuilding everything from scratch, saving a massive amount of time.

## 8. Can I Use My Own Docker?
Absolutely! In fact, this pipeline heavily relies on your own Docker setup. 
Instead of installing C compilers (`gcc`, `cppcheck`) directly onto the GitHub virtual machine, we built a custom `build-env` Docker image. We then used `docker run -d` to start it as a background service, and `docker exec` to run `make lint`, `make test`, and `make build` *inside* the container.
This is a fantastic best practice because it guarantees that your code builds in the exact same environment on GitHub Actions as it does on your local computer.

## 9. Deploying to Your Own Server
Right now, the pipeline creates a GitHub Release. If you wanted to take it a step further and automatically deploy your binary to your own personal server (like an AWS EC2 or DigitalOcean VPS), you could:
1. Add your Server's IP Address, Username, and SSH Private Key as GitHub Secrets.
2. Use an action like `appleboy/ssh-action` to securely SSH into your server directly from the workflow.
3. Send a command to your server to either `docker pull ghcr.io/lucaomsilva/...` to run your image, or use `appleboy/scp-action` to securely copy the compiled `.hex`/binary file directly into your server's file system, then run a command to restart the service.
