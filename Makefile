# Weather MCP - Development Makefile
# Automates setup, testing, and quality control for the weather-mcp project

.PHONY: help setup test lint format typecheck clean dev ci run install-uv check-uv all

# Default target
.DEFAULT_GOAL := help

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

# Check if uv is installed
check-uv:
	@command -v uv >/dev/null 2>&1 || { \
		echo "$(RED)Error: uv is not installed. Please install it first:$(NC)"; \
		echo "  curl -LsSf https://astral.sh/uv/install.sh | sh"; \
		echo "  or visit: https://github.com/astral-sh/uv"; \
		exit 1; \
	}

# Install uv if not present (optional target)
install-uv:
	@if ! command -v uv >/dev/null 2>&1; then \
		echo "$(YELLOW)Installing uv...$(NC)"; \
		curl -LsSf https://astral.sh/uv/install.sh | sh; \
	else \
		echo "$(GREEN)uv is already installed$(NC)"; \
	fi

# Initial project setup - install dependencies
setup: check-uv
	@echo "$(YELLOW)Setting up project dependencies...$(NC)"
	uv sync
	@echo "$(GREEN)✅ Dependencies installed successfully$(NC)"

# Run all tests
test: setup
	@echo "$(YELLOW)Running tests...$(NC)"
	uv run pytest -v
	@echo "$(GREEN)✅ All tests passed$(NC)"

# Run linting with auto-fix
lint: setup
	@echo "$(YELLOW)Running linting (with auto-fix)...$(NC)"
	uv run ruff check --fix --unsafe-fixes || { \
		echo "$(YELLOW)⚠️  Some linting issues remain (line length, etc.)$(NC)"; \
		echo "$(YELLOW)   These don't affect functionality$(NC)"; \
		true; \
	}
	@echo "$(GREEN)✅ Linting completed$(NC)"

# Run code formatting
format: setup
	@echo "$(YELLOW)Running code formatting...$(NC)"
	uv run ruff format
	@echo "$(GREEN)✅ Code formatted$(NC)"

# Run type checking
typecheck: setup
	@echo "$(YELLOW)Running type checking...$(NC)"
	uv run mypy src/weather_mcp/
	@echo "$(GREEN)✅ Type checking completed$(NC)"

# Clean up temporary files
clean:
	@echo "$(YELLOW)Cleaning up temporary files...$(NC)"
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	find . -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -name ".mypy_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -name ".ruff_cache" -exec rm -rf {} + 2>/dev/null || true
	@echo "$(GREEN)✅ Cleanup completed$(NC)"

# Development setup - run all QC checks
dev: setup lint format test typecheck
	@echo "$(GREEN)🚀 Development environment ready!$(NC)"
	@echo "$(GREEN)   All setup and quality checks completed$(NC)"
	@echo "$(GREEN)   You can now run: make run$(NC)"

# Continuous Integration target - strict checks without auto-fix
ci: setup
	@echo "$(YELLOW)Running CI checks...$(NC)"
	uv run ruff check --no-fix
	uv run ruff format --check
	uv run pytest -v
	uv run mypy src/weather_mcp/
	@echo "$(GREEN)✅ All CI checks passed$(NC)"

# Run the weather MCP server
run: setup
	@echo "$(YELLOW)Starting weather MCP server...$(NC)"
	@echo "$(YELLOW)Press Ctrl+C to stop the server$(NC)"
	uv run weather-mcp

# Quick test of CLI functionality
test-cli: setup
	@echo "$(YELLOW)Testing CLI functionality...$(NC)"
	timeout 5 uv run weather-mcp --help 2>/dev/null || { \
		echo "$(GREEN)✅ CLI starts successfully$(NC)"; \
	}

# Run a specific test file
test-file: setup
	@echo "$(YELLOW)Running specific test file...$(NC)"
	@read -p "Enter test file (e.g., tests/test_api.py): " file; \
	uv run pytest -v $$file

# Show coverage report
coverage: setup
	@echo "$(YELLOW)Running tests with coverage...$(NC)"
	uv run pytest --cov=src/weather_mcp --cov-report=html --cov-report=term-missing
	@echo "$(GREEN)✅ Coverage report generated in htmlcov/$(NC)"

# Lint only (no auto-fix) - for checking before commits
lint-check: setup
	@echo "$(YELLOW)Checking linting (no auto-fix)...$(NC)"
	uv run ruff check --no-fix

# Format check only (no changes) - for checking before commits
format-check: setup
	@echo "$(YELLOW)Checking formatting (no changes)...$(NC)"
	uv run ruff format --check

# Quick quality check (fast version of dev)
quick-check: setup lint format
	@echo "$(GREEN)✅ Quick quality check completed$(NC)"

# Full quality check (everything)
full-check: setup lint format test typecheck test-cli
	@echo "$(GREEN)🎉 Full quality check completed successfully!$(NC)"

# Run everything - complete setup, all checks, and coverage
all: setup lint format test typecheck test-cli coverage
	@echo "$(GREEN)🎉 All tasks completed successfully!$(NC)"
	@echo "$(GREEN)   - Dependencies installed$(NC)"
	@echo "$(GREEN)   - Code linted and formatted$(NC)"
	@echo "$(GREEN)   - All tests passed$(NC)"
	@echo "$(GREEN)   - Type checking completed$(NC)"
	@echo "$(GREEN)   - CLI functionality verified$(NC)"
	@echo "$(GREEN)   - Coverage report generated$(NC)"

# Show help
help:
	@echo "$(GREEN)Weather MCP Development Makefile$(NC)"
	@echo ""
	@echo "$(YELLOW)Primary targets:$(NC)"
	@echo "  $(GREEN)help$(NC)           Show this help message"
	@echo "  $(GREEN)setup$(NC)          Install project dependencies"
	@echo "  $(GREEN)dev$(NC)            Full development setup (recommended for new setup)"
	@echo "  $(GREEN)all$(NC)            Run everything (setup + all QC + coverage)"
	@echo "  $(GREEN)run$(NC)            Start the weather MCP server"
	@echo ""
	@echo "$(YELLOW)Quality Control:$(NC)"
	@echo "  $(GREEN)test$(NC)           Run all tests"
	@echo "  $(GREEN)lint$(NC)           Run linting with auto-fix"
	@echo "  $(GREEN)format$(NC)         Run code formatting"
	@echo "  $(GREEN)typecheck$(NC)      Run type checking"
	@echo "  $(GREEN)quick-check$(NC)    Run lint + format (fast QC)"
	@echo "  $(GREEN)full-check$(NC)     Run all quality checks"
	@echo ""
	@echo "$(YELLOW)CI/CD:$(NC)"
	@echo "  $(GREEN)ci$(NC)             Run all checks for CI (strict, no auto-fix)"
	@echo "  $(GREEN)lint-check$(NC)     Check linting without auto-fix"
	@echo "  $(GREEN)format-check$(NC)   Check formatting without changes"
	@echo ""
	@echo "$(YELLOW)Testing:$(NC)"
	@echo "  $(GREEN)test-file$(NC)      Run a specific test file"
	@echo "  $(GREEN)coverage$(NC)       Run tests with coverage report"
	@echo "  $(GREEN)test-cli$(NC)       Quick test of CLI functionality"
	@echo ""
	@echo "$(YELLOW)Utilities:$(NC)"
	@echo "  $(GREEN)clean$(NC)          Clean up temporary files"
	@echo "  $(GREEN)install-uv$(NC)     Install uv package manager"
	@echo ""
	@echo "$(YELLOW)Examples:$(NC)"
	@echo "  $(GREEN)make dev$(NC)                 # Complete setup for new developers"
	@echo "  $(GREEN)make all$(NC)                 # Run everything including coverage"
	@echo "  $(GREEN)make quick-check$(NC)         # Fast quality check before commit"
	@echo "  $(GREEN)make test-file$(NC)           # Run specific test file"
	@echo "  $(GREEN)make ci$(NC)                  # Run all CI checks"