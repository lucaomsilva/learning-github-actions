# First stage: Build environment
FROM alpine:3.24.0 AS build

# Install dependencies
RUN apk add --no-cache \
    gcc=15.2.0-r5 \
    make=4.4.1-r4 \
    musl-dev=1.2.6-r2 \
    cppcheck=2.21.0-r0

# Copy Makefile to build environment
COPY Makefile /build/Makefile

# Set the working directory to /build
WORKDIR /build

# Copy source and test files to build environment
COPY . .
