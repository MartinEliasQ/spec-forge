#!/usr/bin/env bash
# inventory-inbox.sh — List inbox files with line count, size, and type
# Used by /specforge.distill Step 4

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

INBOX_DIR="requirements/inbox"
LARGE_THRESHOLD=500  # lines
JSON_MODE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --json) JSON_MODE=true; shift ;;
        --threshold) LARGE_THRESHOLD="$2"; shift 2 ;;
        *) shift ;;
    esac
done

if [[ ! -d "$INBOX_DIR" ]]; then
    if $JSON_MODE; then
        echo '{"success":false,"error":"Inbox directory not found","path":"'"$INBOX_DIR"'"}'
    else
        echo "ERROR: Inbox directory not found at $INBOX_DIR"
    fi
    exit 1
fi

files=()
while IFS= read -r -d '' f; do
    files+=("$f")
done < <(find "$INBOX_DIR" -maxdepth 1 -type f -print0 2>/dev/null | sort -z)

total=${#files[@]}
large_count=0
binary_count=0

if $JSON_MODE; then
    echo '{"success":true,"inbox_path":"'"$INBOX_DIR"'","files":['
    first=true
    for f in "${files[@]}"; do
        basename=$(basename "$f")
        size_bytes=$(wc -c < "$f" | tr -d ' ')

        # Detect binary
        if file "$f" | grep -q 'text'; then
            is_binary=false
            line_count=$(wc -l < "$f" | tr -d ' ')
            if (( line_count > LARGE_THRESHOLD )); then
                is_large=true
                large_count=$((large_count + 1))
            else
                is_large=false
            fi
            file_type="text"
        else
            is_binary=true
            binary_count=$((binary_count + 1))
            line_count=0
            is_large=false
            file_type="binary"
        fi

        if $first; then
            first=false
        else
            echo ','
        fi
        echo '  {"name":"'"$basename"'","lines":'"$line_count"',"bytes":'"$size_bytes"',"type":"'"$file_type"'","large":'"$is_large"'}'
    done
    echo '],"total":'"$total"',"large_files":'"$large_count"',"binary_files":'"$binary_count"',"large_threshold":'"$LARGE_THRESHOLD"'}'
else
    echo "Inbox Inventory: $INBOX_DIR"
    echo "================================"
    printf "%-40s %8s %10s %8s %s\n" "FILE" "LINES" "SIZE" "TYPE" "WARNING"
    echo "---"
    for f in "${files[@]}"; do
        basename=$(basename "$f")
        size_bytes=$(wc -c < "$f" | tr -d ' ')

        if file "$f" | grep -q 'text'; then
            line_count=$(wc -l < "$f" | tr -d ' ')
            file_type="text"
            if (( line_count > LARGE_THRESHOLD )); then
                warning="LARGE (>$LARGE_THRESHOLD lines)"
                large_count=$((large_count + 1))
            else
                warning=""
            fi
        else
            line_count="-"
            file_type="binary"
            warning="BINARY (will skip)"
            binary_count=$((binary_count + 1))
        fi

        printf "%-40s %8s %10s %8s %s\n" "$basename" "$line_count" "${size_bytes}B" "$file_type" "$warning"
    done
    echo "---"
    echo "Total: $total files | Large: $large_count | Binary: $binary_count"
fi
