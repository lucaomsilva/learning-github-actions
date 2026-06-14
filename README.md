# Learning GitHub Actions

## Description

This project aims to demonstrate and learn how to use GitHub Actions effectively. It includes a simple C software program that prints its version and a "Hello World" message. The software is containerized using Docker, and its build, test, and deployment processes are automated through several GitHub Actions workflows. The versioning is dynamically managed via Git tags or commit hashes.

## Makefile

The Makefile is used to build the software and run tests. It uses the `$(BUILD_DIR)/app` directory to store the built artifacts.

The following commands are available:
- `make build`: Build the software
- `make test`: Test the software
- `make clean`: Clean the build directory

## C Software

The C software is a simple program that prints its version and a "Hello World" message. The version is defined in the git tag or hash and passed to the main function using env variables like:
- `VERSION`: Version of the software (git tag or hash)

The software has a simple unit test using the native C testing library to verify the software.

## Dockerfile

The Docker image uses a multi-stage build process to ensure a minimal footprint:
1. **Build Stage**: Uses `alpine:3.24.0` as the build environment. It installs pinned dependencies (`gcc=15.2.0-r5`, `make=4.4.1-r4`, `musl-dev=1.2.6-r2`), sets up the working directory, copies the source files, and runs the build command while allowing the injection of a `VERSION` argument.
2. **Final Stage**: Uses `alpine:3.24.0` as a minimal runtime environment. It sets up the `/app` working directory and copies only the compiled binary from the build stage, resulting in a small and secure final container.

## CI/CD

The continuous integration and deployment (CI/CD) pipelines are fully automated using GitHub Actions. The pipelines handle code linting, unit testing, building the application, packaging it into a Docker container, and deploying it based on Git tags and releases.

### Workflow Description

- **`lint.yml`**: Runs automatically on pushes and pull requests to the `main` and `develop` branches. It checks out the code, installs `cppcheck` on an `ubuntu-24.04` runner, and performs static analysis on the C source code (`src/` and `tests/`) using a strict configuration (`--enable=all --suppress=missingIncludeSystem --inconclusive --error-exitcode=1`) to enforce code quality and prevent bad code from being merged.
- **`test.yml`**: Triggers simultaneously with the lint workflow on pushes and pull requests to the `main` and `develop` branches. It runs on an `ubuntu-24.04` environment, installs essential build dependencies (`gcc` and `make`), and executes the `make test` command to run the unit tests using the native C testing library, guaranteeing the software works as expected.
- **`build.yml`**: Responsible for checking out the code, setting up the C and Docker build environments, and compiling the software. It builds the Docker image and publishes it to Artifactory. It utilizes GitHub Actions caching, secrets, variables, and extracts the software version dynamically for tagging.
- **`build_and_push.yml`**: Compiles the built Docker images and pushes them to the target container registry, securely utilizing tags for versioning.
- **`deploy.yml`**: Triggered specifically when a new release or Git tag is created. It handles the official deployment and release process for the application.
