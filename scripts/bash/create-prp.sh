#!/usr/bin/env bash

set -e

JSON_MODE=false
for arg in "$@"; do
    case "$arg" in
        --json)
            JSON_MODE=true
            ;;
        --help|-h)
            cat <<'EOF'
Usage: create-prp.sh [--json]

Generate (or refresh) the Product Requirements Prompt for the current feature.

Options:
  --json    Output machine-readable metadata
  --help    Show this message
EOF
            exit 0
            ;;
        *)
            >&2 echo "Unknown argument: $arg"
            exit 1
            ;;
    esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

eval $(get_feature_paths)

check_feature_branch "$CURRENT_BRANCH" "$HAS_GIT" || exit 1

PRP_DIR="$REPO_ROOT/prps"
mkdir -p "$PRP_DIR"

PRP_FILE="$PRP_DIR/$CURRENT_BRANCH.md"
TEMPLATE="$REPO_ROOT/.specify/templates/prp-template.md"

if [[ ! -f "$TEMPLATE" ]]; then
    echo "ERROR: PRP template not found at $TEMPLATE" >&2
    exit 1
fi

current_date=$(date +%Y-%m-%d)

normalize_path() {
    local path="$1"
    local label="$2"
    if [[ -z "$path" ]]; then
        echo "$label missing"
        return
    fi
    if [[ -f "$path" || -d "$path" ]]; then
        echo "$path"
    else
        echo "$path (missing)"
    fi
}

spec_path=$(normalize_path "$FEATURE_SPEC" "Specification")
plan_path=$(normalize_path "$IMPL_PLAN" "Implementation plan")
tasks_path=$(normalize_path "$TASKS" "Tasks backlog")
research_path=$(normalize_path "$RESEARCH" "Research")
data_model_path=$(normalize_path "$DATA_MODEL" "Data model")
contracts_path=$(normalize_path "$CONTRACTS_DIR" "Contracts directory")
quickstart_path=$(normalize_path "$QUICKSTART" "Quickstart guide")

python3 - "$TEMPLATE" "$PRP_FILE" \
    "$CURRENT_BRANCH" \
    "$current_date" \
    "$spec_path" \
    "$plan_path" \
    "$tasks_path" \
    "$research_path" \
    "$data_model_path" \
    "$contracts_path" \
    "$quickstart_path" <<'PY'
import sys, pathlib

template_path = pathlib.Path(sys.argv[1])
output_path = pathlib.Path(sys.argv[2])

content = template_path.read_text()

keys = [
    "FEATURE_BRANCH",
    "CURRENT_DATE",
    "SPEC_PATH",
    "PLAN_PATH",
    "TASKS_PATH",
    "RESEARCH_PATH",
    "DATA_MODEL_PATH",
    "CONTRACTS_PATH",
    "QUICKSTART_PATH",
]

values = sys.argv[3:3 + len(keys)]

for key, value in zip(keys, values):
    content = content.replace(f"{{{{{key}}}}}", value)

output_path.write_text(content)
PY

if $JSON_MODE; then
    printf '{"PRP_FILE":"%s","FEATURE_BRANCH":"%s"}\n' "$PRP_FILE" "$CURRENT_BRANCH"
else
    echo "PRP_FILE: $PRP_FILE"
    echo "FEATURE_BRANCH: $CURRENT_BRANCH"
fi
