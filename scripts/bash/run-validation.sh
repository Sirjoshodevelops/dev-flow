#!/usr/bin/env bash

set -e

JSON_MODE=false
FOCUS=""

for arg in "$@"; do
    case "$arg" in
        --json) JSON_MODE=true ;;
        --focus=*) FOCUS="${arg#*=}" ;;
        --help|-h)
            echo "Usage: $0 [--json] [--focus=<phase>]"
            echo "  --json       Output in JSON format"
            echo "  --focus      Focus on specific validation phase (requirements|budget|consistency|constitution|practices)"
            exit 0
            ;;
    esac
done

# Find repository root
find_repo_root() {
    local dir="$1"
    while [ "$dir" != "/" ]; do
        if [ -d "$dir/.git" ] || [ -d "$dir/.specify" ]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    return 1
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if git rev-parse --show-toplevel >/dev/null 2>&1; then
    REPO_ROOT=$(git rev-parse --show-toplevel)
    HAS_GIT=true
else
    REPO_ROOT="$(find_repo_root "$SCRIPT_DIR")"
    if [ -z "$REPO_ROOT" ]; then
        echo "Error: Could not determine repository root." >&2
        exit 1
    fi
    HAS_GIT=false
fi

cd "$REPO_ROOT"

# Get current branch/feature
if [ "$HAS_GIT" = true ]; then
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
else
    # Try to get from environment variable
    CURRENT_BRANCH="${SPECIFY_FEATURE:-unknown}"
fi

# Determine specs directory
SPECS_DIR="$REPO_ROOT/specs"
FEATURE_DIR=""

# Try to find feature directory
if [ "$CURRENT_BRANCH" != "main" ] && [ "$CURRENT_BRANCH" != "master" ] && [ "$CURRENT_BRANCH" != "unknown" ]; then
    FEATURE_DIR="$SPECS_DIR/$CURRENT_BRANCH"
fi

# If feature dir doesn't exist, try to find most recent
if [ ! -d "$FEATURE_DIR" ]; then
    if [ -d "$SPECS_DIR" ]; then
        FEATURE_DIR=$(find "$SPECS_DIR" -mindepth 1 -maxdepth 1 -type d | sort -r | head -1)
    fi
fi

# Validation output directory
VALIDATION_DIR="$REPO_ROOT/.specify/validation"
mkdir -p "$VALIDATION_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
VALIDATION_REPORT="$VALIDATION_DIR/validation-report-$TIMESTAMP.md"

# Load validation config if exists
CONFIG_FILE="$REPO_ROOT/.specify/validation-config.json"
if [ -f "$CONFIG_FILE" ]; then
    HAS_CONFIG=true
else
    HAS_CONFIG=false
fi

# Check if common utilities are available
check_tool() {
    command -v "$1" >/dev/null 2>&1
}

# Detect language and available tools
PYTHON_AVAILABLE=$(check_tool python3 && echo "true" || echo "false")
NODE_AVAILABLE=$(check_tool node && echo "true" || echo "false")
MARKDOWNLINT_AVAILABLE=$(check_tool markdownlint && echo "true" || echo "false")

# Output in JSON format
if $JSON_MODE; then
    cat << EOF
{
  "REPO_ROOT": "$REPO_ROOT",
  "CURRENT_BRANCH": "$CURRENT_BRANCH",
  "SPECS_DIR": "$SPECS_DIR",
  "FEATURE_DIR": "$FEATURE_DIR",
  "VALIDATION_REPORT": "$VALIDATION_REPORT",
  "HAS_GIT": $HAS_GIT,
  "HAS_CONFIG": $HAS_CONFIG,
  "FOCUS": "$FOCUS",
  "TOOLS": {
    "python": $PYTHON_AVAILABLE,
    "node": $NODE_AVAILABLE,
    "markdownlint": $MARKDOWNLINT_AVAILABLE
  }
}
EOF
else
    echo "REPO_ROOT: $REPO_ROOT"
    echo "CURRENT_BRANCH: $CURRENT_BRANCH"
    echo "SPECS_DIR: $SPECS_DIR"
    echo "FEATURE_DIR: $FEATURE_DIR"
    echo "VALIDATION_REPORT: $VALIDATION_REPORT"
    echo "HAS_GIT: $HAS_GIT"
    echo "HAS_CONFIG: $HAS_CONFIG"
    echo "FOCUS: $FOCUS"
    echo ""
    echo "Available validation tools:"
    echo "  Python: $PYTHON_AVAILABLE"
    echo "  Node: $NODE_AVAILABLE"
    echo "  markdownlint: $MARKDOWNLINT_AVAILABLE"
fi
