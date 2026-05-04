#!/usr/bin/env bash
# Run all tests in tests/test_*.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

failed=0
passed=0
total=0

for t in tests/test_*.sh; do
    total=$((total + 1))
    echo "── $t"
    if bash "$t"; then
        passed=$((passed + 1))
    else
        failed=$((failed + 1))
    fi
    echo
done

echo "============================="
echo "Passed: $passed / $total"
if [ "$failed" -gt 0 ]; then
    echo "Failed: $failed"
    exit 1
fi
