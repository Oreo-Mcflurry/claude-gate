#!/usr/bin/env bash
set -euo pipefail

PACKAGE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

case "${1:-install}" in
  install)
    bash "$PACKAGE_DIR/install.sh"
    ;;
  uninstall)
    bash "$PACKAGE_DIR/uninstall.sh"
    ;;
  *)
    echo "Usage: claude-gate [install|uninstall]"
    echo ""
    echo "  install     Install Claude Gate (default)"
    echo "  uninstall   Remove Claude Gate"
    exit 1
    ;;
esac
