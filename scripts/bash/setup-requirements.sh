#!/usr/bin/env bash

set -e

# Parse command line arguments
JSON_MODE=false

for arg in "$@"; do
    case "$arg" in
        --json) JSON_MODE=true ;;
        --help|-h)
            echo "Usage: $0 [--json]"
            echo "  --json    Output results in JSON format"
            echo "  --help    Show this help message"
            exit 0
            ;;
    esac
done

# Get script directory and load common functions
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

REPO_ROOT=$(get_repo_root)
REQ_DIR="$REPO_ROOT/requirements"

DIRS_CREATED=()
INDEX_CREATED=false
ANY_CREATED=false

# Create directories if missing
for subdir in inbox synthesis units features; do
    target="$REQ_DIR/$subdir"
    if [[ ! -d "$target" ]]; then
        mkdir -p "$target"
        DIRS_CREATED+=("$subdir")
        ANY_CREATED=true
    fi
done

# Create index.md if missing
if [[ ! -f "$REQ_DIR/index.md" ]]; then
    cat > "$REQ_DIR/index.md" << 'INDEXEOF'
# Requirements Index

**Last updated**: —

## Features

| Feature ID | Name | Status | Units |
|------------|------|--------|-------|

## Statistics

- **Total inbox files**: 0
- **Total units**: 0
- **Total features**: 0
- **Ready**: 0 | **Needs Refinement**: 0 | **Blocked**: 0
INDEXEOF
    INDEX_CREATED=true
    ANY_CREATED=true
fi

# Output results
if $JSON_MODE; then
    # Build directories_created JSON array
    dirs_json="[]"
    if [[ ${#DIRS_CREATED[@]} -gt 0 ]]; then
        if has_jq; then
            dirs_json=$(printf '%s\n' "${DIRS_CREATED[@]}" | jq -R . | jq -s .)
        else
            dirs_json="["
            first=true
            for d in "${DIRS_CREATED[@]}"; do
                if $first; then first=false; else dirs_json+=","; fi
                dirs_json+="\"$(json_escape "$d")\""
            done
            dirs_json+="]"
        fi
    fi

    if has_jq; then
        jq -cn \
            --argjson created "$ANY_CREATED" \
            --arg requirements_dir "$REQ_DIR" \
            --arg inbox_dir "$REQ_DIR/inbox" \
            --argjson directories_created "$dirs_json" \
            --argjson index_created "$INDEX_CREATED" \
            '{created:$created,requirements_dir:$requirements_dir,inbox_dir:$inbox_dir,directories_created:$directories_created,index_created:$index_created}'
    else
        printf '{"created":%s,"requirements_dir":"%s","inbox_dir":"%s","directories_created":%s,"index_created":%s}\n' \
            "$ANY_CREATED" \
            "$(json_escape "$REQ_DIR")" \
            "$(json_escape "$REQ_DIR/inbox")" \
            "$dirs_json" \
            "$INDEX_CREATED"
    fi
else
    if $ANY_CREATED; then
        echo "Requirements structure created at: $REQ_DIR"
        [[ ${#DIRS_CREATED[@]} -gt 0 ]] && echo "  Directories: ${DIRS_CREATED[*]}"
        $INDEX_CREATED && echo "  Index: index.md"
    else
        echo "Requirements structure already exists at: $REQ_DIR"
    fi
fi
