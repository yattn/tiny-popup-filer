#!/bin/bash
# Test script for tiny-popup-filer (run from anywhere)

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Testing tiny-popup-filer..."
echo "Starting Vim with plugin..."

vim --cmd "set rtp+=${PROJECT_DIR}" -c "Tpf" -c "echo 'Plugin loaded successfully. Use j/k/h/l/Enter/c to navigate. Press x or Esc to exit.'"