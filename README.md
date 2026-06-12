# Learning GitHub Actions

## Description

This project aims to demonstrate and learn how to use GitHub Actions effectively. It includes a simple C software program that prints its version and a "Hello World" message. The software is containerized using Docker, and its build, test, and deployment processes are automated through several GitHub Actions workflows. The versioning is dynamically managed via Git tags or commit hashes.

## Dockerfile

The Docker image uses a multi-stage build process to ensure a minimal footprint:
1. **Build Stage**: Uses a base image (e.g., `alpine` or `ubuntu` with pinned, static versions) containing the necessary C build tools (`gcc`, `make`) to compile the application.
2. **Final Stage**: A minimal base image that copies the compiled binary from the build stage, resulting in a small and secure final container.

## CI/CD

The continuous integration and deployment (CI/CD) pipelines are fully automated using GitHub Actions. The pipelines handle code linting, unit testing, building the application, packaging it into a Docker container, and deploying it based on Git tags and releases.

### Workflow Description

- **`lint-and-test.yml`**: Runs automatically to lint the C source code and execute unit tests via the native C testing library, ensuring code quality and correctness.
- **`build.yml`**: Responsible for checking out the code, setting up the C and Docker build environments, and compiling the software. It builds the Docker image and publishes it to Artifactory. It utilizes GitHub Actions caching, secrets, variables, and extracts the software version dynamically for tagging.
- **`build_and_push.yml`**: Compiles the built Docker images and pushes them to the target container registry, securely utilizing tags for versioning.
- **`deploy.yml`**: Triggered specifically when a new release or Git tag is created. It handles the official deployment and release process for the application.
