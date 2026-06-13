# First stage: Build environment
FROM alpine:3.24.0 AS build

# Install dependencies
RUN apk add --no-cache \
    gcc=15.2.0-r5 \
    make=4.4.1-r4 \
    musl-dev=1.2.6-r2

# Copy Makefile to build environment
COPY Makefile /build/Makefile

# Set the working directory to /build
WORKDIR /build

# Copy source and test files to build environment
COPY . .

# Declare an ARG to allow injecting the version
ARG VERSION=unknown

# Run the build command, passing the version
RUN make build VERSION=${VERSION}

# Second stage: Minimal runtime environment
FROM alpine:3.24.0

# Set the working directory to /app
WORKDIR /app

# Copy only the compiled binary from the build stage
COPY --from=build /build/bin/app /app/app

ENTRYPOINT ["/app/app"]
