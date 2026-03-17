#!/usr/bin/env bash

set -e

# Parse command line arguments
JSON_MODE=false
FEATURE_NAME=""
FEATURE_NUMBER=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --json) JSON_MODE=true; shift ;;
        --name) FEATURE_NAME="$2"; shift 2 ;;
        --number) FEATURE_NUMBER="$2"; shift 2 ;;
        --help|-h)
            echo "Usage: $0 --name <feature-name> --number <NNN> [--json]"
            echo "  --name    Feature name (will be kebab-cased)"
            echo "  --number  Feature number (zero-padded to 3 digits)"
            echo "  --json    Output results in JSON format"
            exit 0
            ;;
        *) shift ;;
    esac
done

if [[ -z "$FEATURE_NAME" || -z "$FEATURE_NUMBER" ]]; then
    echo "ERROR: --name and --number are required" >&2
    exit 1
fi

# Get script directory and load common functions
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

REPO_ROOT=$(get_repo_root)
REQ_DIR="$REPO_ROOT/requirements"
TEMPLATES_DIR="$REPO_ROOT/templates"

# Convert name to kebab-case
KEBAB_NAME=$(echo "$FEATURE_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')

# Zero-pad number
PADDED_NUMBER=$(printf "%03d" "$FEATURE_NUMBER")

FEATURE_ID="FEAT-${PADDED_NUMBER}-${KEBAB_NAME}"
FEATURE_DIR="$REQ_DIR/features/$FEATURE_ID"

# Check if directory already exists
if [[ -d "$FEATURE_DIR" ]]; then
    echo "ERROR: Feature directory already exists: $FEATURE_DIR" >&2
    exit 1
fi

# Create feature directory
mkdir -p "$FEATURE_DIR"

# Copy templates
FILES_CREATED=()
for template in feature-requirement.md feature-includes.md feature-sources.md feature-readiness.md; do
    # Map template name to output filename
    case "$template" in
        feature-requirement.md) outfile="requirement.md" ;;
        feature-includes.md)    outfile="includes.md" ;;
        feature-sources.md)     outfile="sources.md" ;;
        feature-readiness.md)   outfile="readiness.md" ;;
    esac

    if [[ -f "$TEMPLATES_DIR/$template" ]]; then
        cp "$TEMPLATES_DIR/$template" "$FEATURE_DIR/$outfile"
    else
        touch "$FEATURE_DIR/$outfile"
    fi
    FILES_CREATED+=("$outfile")
done

# Output results
if $JSON_MODE; then
    # Build files_created JSON array
    if has_jq; then
        files_json=$(printf '%s\n' "${FILES_CREATED[@]}" | jq -R . | jq -s .)
        jq -cn \
            --arg feature_id "$FEATURE_ID" \
            --arg feature_dir "$FEATURE_DIR" \
            --argjson files_created "$files_json" \
            '{feature_id:$feature_id,feature_dir:$feature_dir,files_created:$files_created}'
    else
        files_json="["
        first=true
        for f in "${FILES_CREATED[@]}"; do
            if $first; then first=false; else files_json+=","; fi
            files_json+="\"$(json_escape "$f")\""
        done
        files_json+="]"
        printf '{"feature_id":"%s","feature_dir":"%s","files_created":%s}\n' \
            "$(json_escape "$FEATURE_ID")" \
            "$(json_escape "$FEATURE_DIR")" \
            "$files_json"
    fi
else
    echo "Feature created: $FEATURE_ID"
    echo "Directory: $FEATURE_DIR"
    echo "Files: ${FILES_CREATED[*]}"
fi
