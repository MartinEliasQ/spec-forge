#!/usr/bin/env bash

set -e

# Parse command line arguments
JSON_MODE=false
PHASE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --json) JSON_MODE=true; shift ;;
        --phase) PHASE="$2"; shift 2 ;;
        --help|-h)
            echo "Usage: $0 --phase distill|clarify|compose|status [--json]"
            echo "  --phase   Phase to validate prerequisites for"
            echo "  --json    Output results in JSON format"
            exit 0
            ;;
        *) shift ;;
    esac
done

if [[ -z "$PHASE" ]]; then
    echo "ERROR: --phase is required (distill|clarify|compose|status)" >&2
    exit 2
fi

if [[ "$PHASE" != "distill" && "$PHASE" != "clarify" && "$PHASE" != "compose" && "$PHASE" != "status" ]]; then
    echo "ERROR: Invalid phase '$PHASE'. Must be distill, clarify, compose, or status" >&2
    exit 2
fi

# Get script directory and load common functions
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

REPO_ROOT=$(get_repo_root)
REQ_DIR="$REPO_ROOT/requirements"
MISSING=()
VALID_BRANCH=true

# Check branch format (warning only)
if has_git; then
    BRANCH=$(get_current_branch)
    if [[ ! "$BRANCH" =~ ^[0-9]{3}- ]]; then
        VALID_BRANCH=false
        echo "[specforge] Warning: Branch '$BRANCH' does not follow NNN-feature-name convention" >&2
    fi
fi

# Check requirements directory exists
if [[ ! -d "$REQ_DIR" ]]; then
    echo "ERROR: requirements/ directory does not exist. Run setup-requirements.sh first." >&2
    exit 2
fi

# Phase-specific validations
case "$PHASE" in
    distill)
        if [[ ! -d "$REQ_DIR/inbox" ]]; then
            MISSING+=("requirements/inbox/ (directory missing)")
        else
            # Check for at least one text file
            has_files=false
            for f in "$REQ_DIR/inbox"/*; do
                if [[ -f "$f" ]]; then
                    has_files=true
                    break
                fi
            done
            if ! $has_files; then
                MISSING+=("requirements/inbox/ (no files found)")
            fi
        fi
        ;;
    clarify)
        # Check units directory has files (clarify only needs units, not synthesis)
        if [[ ! -d "$REQ_DIR/units" ]]; then
            MISSING+=("requirements/units/ (directory missing)")
        else
            has_units=false
            for f in "$REQ_DIR/units"/UNIT-*.md; do
                if [[ -f "$f" ]]; then
                    has_units=true
                    break
                fi
            done
            if ! $has_units; then
                MISSING+=("requirements/units/ (empty — run /specforge.distill first)")
            fi
        fi
        ;;
    compose)
        # Check units directory has files
        if [[ ! -d "$REQ_DIR/units" ]]; then
            MISSING+=("requirements/units/ (directory missing)")
        else
            has_units=false
            for f in "$REQ_DIR/units"/UNIT-*.md; do
                if [[ -f "$f" ]]; then
                    has_units=true
                    break
                fi
            done
            if ! $has_units; then
                MISSING+=("requirements/units/ (empty)")
            fi
        fi
        # Check synthesis overview exists
        if [[ ! -f "$REQ_DIR/synthesis/overview.md" ]]; then
            MISSING+=("requirements/synthesis/overview.md")
        fi
        ;;
    status)
        if [[ ! -d "$REQ_DIR/features" ]]; then
            MISSING+=("requirements/features/ (directory missing)")
        else
            has_features=false
            for d in "$REQ_DIR/features"/FEAT-*; do
                if [[ -d "$d" && -f "$d/requirement.md" ]]; then
                    has_features=true
                    break
                fi
            done
            if ! $has_features; then
                MISSING+=("requirements/features/ (no feature directories with requirement.md)")
            fi
        fi
        ;;
esac

READY=true
if [[ ${#MISSING[@]} -gt 0 ]]; then
    READY=false
fi

# Output results
if $JSON_MODE; then
    # Build missing JSON array
    missing_json="[]"
    if [[ ${#MISSING[@]} -gt 0 ]]; then
        if has_jq; then
            missing_json=$(printf '%s\n' "${MISSING[@]}" | jq -R . | jq -s .)
        else
            missing_json="["
            first=true
            for m in "${MISSING[@]}"; do
                if $first; then first=false; else missing_json+=","; fi
                missing_json+="\"$(json_escape "$m")\""
            done
            missing_json+="]"
        fi
    fi

    if has_jq; then
        jq -cn \
            --arg phase "$PHASE" \
            --argjson valid_branch "$VALID_BRANCH" \
            --arg requirements_dir "$REQ_DIR" \
            --argjson missing "$missing_json" \
            --argjson ready "$READY" \
            '{phase:$phase,valid_branch:$valid_branch,requirements_dir:$requirements_dir,missing:$missing,ready:$ready}'
    else
        printf '{"phase":"%s","valid_branch":%s,"requirements_dir":"%s","missing":%s,"ready":%s}\n' \
            "$(json_escape "$PHASE")" \
            "$VALID_BRANCH" \
            "$(json_escape "$REQ_DIR")" \
            "$missing_json" \
            "$READY"
    fi

    if ! $READY; then
        exit 1
    fi
else
    echo "Phase: $PHASE"
    echo "Requirements dir: $REQ_DIR"
    echo "Valid branch: $VALID_BRANCH"
    if $READY; then
        echo "Status: READY"
    else
        echo "Status: NOT READY"
        echo "Missing:"
        for m in "${MISSING[@]}"; do
            echo "  - $m"
        done
        exit 1
    fi
fi
