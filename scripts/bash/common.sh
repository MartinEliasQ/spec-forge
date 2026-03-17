#!/usr/bin/env bash
# Common functions and variables for SpecForge scripts

# Get repository root, with fallback for non-git repositories
get_repo_root() {
    if git rev-parse --show-toplevel >/dev/null 2>&1; then
        git rev-parse --show-toplevel
    else
        local script_dir="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        (cd "$script_dir/../.." && pwd)
    fi
}

# Get current branch, with fallback for non-git repositories
get_current_branch() {
    if git rev-parse --abbrev-ref HEAD >/dev/null 2>&1; then
        git rev-parse --abbrev-ref HEAD
        return
    fi
    echo "main"
}

# Check if we have git available
has_git() {
    git rev-parse --show-toplevel >/dev/null 2>&1
}

# Check if jq is available for safe JSON construction
has_jq() {
    command -v jq >/dev/null 2>&1
}

# Escape a string for safe embedding in a JSON value
json_escape() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\t'/\\t}"
    s="${s//$'\r'/\\r}"
    printf '%s' "$s"
}

check_file() { [[ -f "$1" ]] && echo "  ✓ $2" || echo "  ✗ $2"; }
check_dir() { [[ -d "$1" && -n $(ls -A "$1" 2>/dev/null) ]] && echo "  ✓ $2" || echo "  ✗ $2"; }

# SpecForge-specific helpers

# Get the requirements directory path
get_requirements_dir() {
    local repo_root
    repo_root=$(get_repo_root)
    echo "$repo_root/requirements"
}

# Get all requirements-related paths as shell variables
get_requirements_paths() {
    local repo_root
    repo_root=$(get_repo_root)
    local req_dir="$repo_root/requirements"

    printf 'REPO_ROOT=%q\n' "$repo_root"
    printf 'REQUIREMENTS_DIR=%q\n' "$req_dir"
    printf 'INBOX_DIR=%q\n' "$req_dir/inbox"
    printf 'SYNTHESIS_DIR=%q\n' "$req_dir/synthesis"
    printf 'UNITS_DIR=%q\n' "$req_dir/units"
    printf 'FEATURES_DIR=%q\n' "$req_dir/features"
    printf 'INDEX_FILE=%q\n' "$req_dir/index.md"
}
