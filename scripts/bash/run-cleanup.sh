#!/usr/bin/env bash

set -e

JSON_MODE=false
CLEANUP_TYPE="all"
DRY_RUN=true
ARCHIVE_ONLY=false

for arg in "$@"; do
    case "$arg" in
        --json) JSON_MODE=true ;;
        --type=*) CLEANUP_TYPE="${arg#*=}" ;;
        --execute) DRY_RUN=false ;;
        --archive-only) ARCHIVE_ONLY=true ;;
        --help|-h)
            echo "Usage: $0 [--json] [--type=<type>] [--execute] [--archive-only]"
            echo "  --json          Output in JSON format"
            echo "  --type          Cleanup type (dead-code|duplicates|unused-files|outdated-docs|all)"
            echo "  --execute       Execute cleanup (default is dry-run)"
            echo "  --archive-only  Move to archive instead of deleting"
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

# Safety checks
if [ "$HAS_GIT" = true ]; then
    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        echo "Error: You have uncommitted changes. Please commit or stash them before running cleanup." >&2
        exit 1
    fi
    
    # Get current branch
    CURRENT_BRANCH=$(git branch --show-current)
    
    # Create backup branch
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_BRANCH="cleanup-backup-$TIMESTAMP"
    git branch "$BACKUP_BRANCH"
else
    CURRENT_BRANCH="${SPECIFY_FEATURE:-main}"
    BACKUP_BRANCH="manual-backup-required"
fi

# Create cleanup directory
CLEANUP_DIR="$REPO_ROOT/.specify/cleanup"
mkdir -p "$CLEANUP_DIR"

CLEANUP_REPORT="$CLEANUP_DIR/cleanup-report-$TIMESTAMP.md"

# Create archive directory
ARCHIVE_DIR="$REPO_ROOT/.archived"
mkdir -p "$ARCHIVE_DIR/$(date +%Y-%m)"

# Load cleanup config if exists
CONFIG_FILE="$REPO_ROOT/.specify/cleanup-config.json"
if [ -f "$CONFIG_FILE" ]; then
    HAS_CONFIG=true
else
    HAS_CONFIG=false
fi

# Check available tools
check_tool() {
    command -v "$1" >/dev/null 2>&1
}

# Detect language and tools
PYTHON_AVAILABLE=$(check_tool python3 && echo "true" || echo "false")
NODE_AVAILABLE=$(check_tool node && echo "true" || echo "false")
VULTURE_AVAILABLE=$(check_tool vulture && echo "true" || echo "false")
TSPRUNE_AVAILABLE=$(check_tool ts-prune && echo "true" || echo "false")
PYLINT_AVAILABLE=$(check_tool pylint && echo "true" || echo "false")

# Detect project languages
detect_languages() {
    local langs=()
    [ -n "$(find . -name '*.py' -type f 2>/dev/null | head -1)" ] && langs+=("python")
    [ -n "$(find . -name '*.js' -o -name '*.ts' -type f 2>/dev/null | head -1)" ] && langs+=("javascript")
    [ -n "$(find . -name '*.go' -type f 2>/dev/null | head -1)" ] && langs+=("go")
    [ -n "$(find . -name '*.rs' -type f 2>/dev/null | head -1)" ] && langs+=("rust")
    echo "${langs[@]}"
}

PROJECT_LANGUAGES=$(detect_languages)

# Output in JSON format
if $JSON_MODE; then
    cat << EOF
{
  "REPO_ROOT": "$REPO_ROOT",
  "CURRENT_BRANCH": "$CURRENT_BRANCH",
  "BACKUP_BRANCH": "$BACKUP_BRANCH",
  "CLEANUP_REPORT": "$CLEANUP_REPORT",
  "ARCHIVE_DIR": "$ARCHIVE_DIR",
  "HAS_GIT": $HAS_GIT,
  "HAS_CONFIG": $HAS_CONFIG,
  "CLEANUP_TYPE": "$CLEANUP_TYPE",
  "DRY_RUN": $DRY_RUN,
  "ARCHIVE_ONLY": $ARCHIVE_ONLY,
  "PROJECT_LANGUAGES": "$(echo $PROJECT_LANGUAGES | tr ' ' ',')",
  "TOOLS": {
    "python": $PYTHON_AVAILABLE,
    "node": $NODE_AVAILABLE,
    "vulture": $VULTURE_AVAILABLE,
    "ts-prune": $TSPRUNE_AVAILABLE,
    "pylint": $PYLINT_AVAILABLE
  }
}
EOF
else
    echo "REPO_ROOT: $REPO_ROOT"
    echo "CURRENT_BRANCH: $CURRENT_BRANCH"
    echo "BACKUP_BRANCH: $BACKUP_BRANCH"
    echo "CLEANUP_REPORT: $CLEANUP_REPORT"
    echo "ARCHIVE_DIR: $ARCHIVE_DIR"
    echo "HAS_GIT: $HAS_GIT"
    echo "CLEANUP_TYPE: $CLEANUP_TYPE"
    echo "DRY_RUN: $DRY_RUN"
    echo "ARCHIVE_ONLY: $ARCHIVE_ONLY"
    echo ""
    echo "Project languages detected: $PROJECT_LANGUAGES"
    echo ""
    echo "Available cleanup tools:"
    echo "  Python: $PYTHON_AVAILABLE"
    echo "  Node: $NODE_AVAILABLE"
    echo "  vulture: $VULTURE_AVAILABLE"
    echo "  ts-prune: $TSPRUNE_AVAILABLE"
    echo "  pylint: $PYLINT_AVAILABLE"
    echo ""
    echo "⚠️  SAFETY: Backup branch created: $BACKUP_BRANCH"
    if [ "$HAS_GIT" = true ]; then
        echo "   Rollback command: git reset --hard $BACKUP_BRANCH"
    else
        echo "   Please create manual backup before proceeding"
    fi
fi
