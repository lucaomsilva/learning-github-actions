# Compiler and flags
CC = gcc
CFLAGS = -Wall -Wextra -I./src -static

# Directory for built artifacts
BUILD_DIR = bin

# Determine version from git tag/hash if available
VERSION ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo "unknown")

# Provide a fallback compile-time version
CFLAGS += -DAPP_VERSION=\"$(VERSION)\"

# Targets
TARGET = $(BUILD_DIR)/app
TEST_TARGET = $(BUILD_DIR)/test_app

# Source directories
SRC_DIRS = src
TEST_DIRS = tests

# Source files
SRC = $(SRC_DIRS)/main.c $(SRC_DIRS)/hello/hello.c
TEST_SRC = $(TEST_DIRS)/test_hello.c $(SRC_DIRS)/hello/hello.c

# Color output
BLUE=\033[0;34m
GREEN=\033[0;32m
YELLOW=\033[0;33m
RED=\033[0;31m
NC=\033[0m # No Color

##@ General

.PHONY: help
help: ## Display this help message
	@echo -e "$(BLUE)Learning GitHub Actions Makefile$(NC)"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "Usage:\n  make $(GREEN)<target>$(NC)\n"} /^[a-zA-Z_0-9\/-]+:.*?##/ { printf "  $(GREEN)%-5s$(NC) %s\n", $$1, $$2 } /^##@/ { printf "\n$(BLUE)%s$(NC)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@echo ""

##@ Build

$(BUILD_DIR): ## Create the build directory
	@echo -e "$(BLUE)Creating build directory...$(NC)"
	@mkdir -p $(BUILD_DIR)
	@echo -e "$(GREEN)Build directory created!$(NC)"

.PHONY: build
build: $(TARGET) ## Build the software

$(TARGET): $(SRC) | $(BUILD_DIR) ## Build the software
	@$(CC) $(CFLAGS) $(SRC) -o $(TARGET)
	
##@ Lint

.PHONY: lint
lint: ## Lint the C code
	@echo -e "$(BLUE)Linting C code...$(NC)"
	@cppcheck --enable=all --suppress=missingIncludeSystem --inconclusive --error-exitcode=1 $(SRC_DIRS) $(TEST_DIRS)
	@echo -e "$(GREEN)Lint completed!$(NC)"

##@ Tests

.PHONY: test
test: $(TEST_TARGET) ## Run the tests
	@echo -e "$(BLUE)Running tests...$(NC)"
	@./$(TEST_TARGET)
	@echo -e "$(GREEN)Test completed!$(NC)"

$(TEST_TARGET): $(TEST_SRC) | $(BUILD_DIR) ## Compile the tests
	@$(CC) $(CFLAGS) $(TEST_SRC) -o $(TEST_TARGET)

##@ Clean

.PHONY: clean
clean: ## Clean the build directory
	@echo -e "$(BLUE)Cleaning build directory...$(NC)"
	@rm -rf $(BUILD_DIR)
	@echo -e "$(GREEN)Build directory cleaned!$(NC)"
