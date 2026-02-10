#!/usr/bin/env bash
set -euo pipefail

# Claude Gate - Uninstallation Script
# Removes the 4-Phase Quality Gate System from Claude Code

CLAUDE_DIR="$HOME/.claude"
AGENTS_DIR="$CLAUDE_DIR/agents"
COMMANDS_DIR="$CLAUDE_DIR/commands"
CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"

AGENTS=(
  "gate-keeper.md"
  "spec-reviewer.md"
  "design-reviewer.md"
  "code-reviewer.md"
  "security-reviewer.md"
)

echo "=== Claude Gate Uninstaller ==="
echo ""

# 1. Remove agent files
removed=0
for agent in "${AGENTS[@]}"; do
  if [ -f "$AGENTS_DIR/$agent" ]; then
    rm "$AGENTS_DIR/$agent"
    ((removed++))
  fi
done
echo "[1/3] Removed $removed agent(s) from $AGENTS_DIR"

# 2. Remove gate command
if [ -f "$COMMANDS_DIR/gate.md" ]; then
  rm "$COMMANDS_DIR/gate.md"
  echo "[2/3] Removed /gate command from $COMMANDS_DIR"
else
  echo "[2/3] /gate command not found (skipped)"
fi

# 3. Remove Gate System section from CLAUDE.md
if [ -f "$CLAUDE_MD" ] && grep -q "GATE-SYSTEM-START" "$CLAUDE_MD"; then
  # Use sed to remove everything between markers (inclusive)
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' '/<!-- GATE-SYSTEM-START -->/,/<!-- GATE-SYSTEM-END -->/d' "$CLAUDE_MD"
  else
    sed -i '/<!-- GATE-SYSTEM-START -->/,/<!-- GATE-SYSTEM-END -->/d' "$CLAUDE_MD"
  fi
  # Remove trailing blank lines left behind
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$CLAUDE_MD"
  else
    sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$CLAUDE_MD"
  fi
  echo "[3/3] Removed Gate System section from CLAUDE.md"
else
  echo "[3/3] Gate System not found in CLAUDE.md (skipped)"
fi

echo ""
echo "Claude Gate has been uninstalled."
