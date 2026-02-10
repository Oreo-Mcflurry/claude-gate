#!/usr/bin/env bash
set -euo pipefail

# Claude Gate - Installation Script
# Installs the 4-Phase Quality Gate System for Claude Code

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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

echo "=== Claude Gate Installer ==="
echo ""

# 1. Check Claude Code installation
if [ ! -d "$CLAUDE_DIR" ]; then
  echo "Error: ~/.claude directory not found."
  echo "Please install Claude Code first: https://docs.anthropic.com/en/docs/claude-code"
  exit 1
fi
echo "[1/5] Claude Code detected."

# 2. Copy agent files
mkdir -p "$AGENTS_DIR"
for agent in "${AGENTS[@]}"; do
  if [ ! -f "$SCRIPT_DIR/agents/$agent" ]; then
    echo "Error: Missing agent file: agents/$agent"
    exit 1
  fi
  cp "$SCRIPT_DIR/agents/$agent" "$AGENTS_DIR/$agent"
done
echo "[2/5] Installed ${#AGENTS[@]} agents to $AGENTS_DIR"

# 3. Copy gate command
mkdir -p "$COMMANDS_DIR"
if [ ! -f "$SCRIPT_DIR/commands/gate.md" ]; then
  echo "Error: Missing command file: commands/gate.md"
  exit 1
fi
cp "$SCRIPT_DIR/commands/gate.md" "$COMMANDS_DIR/gate.md"
echo "[3/5] Installed /gate command to $COMMANDS_DIR"

# 4. Append snippet to CLAUDE.md (if not already present)
if [ -f "$CLAUDE_MD" ] && grep -q "GATE-SYSTEM-START" "$CLAUDE_MD"; then
  echo "[4/5] Gate System already present in CLAUDE.md (skipped)"
else
  # Backup existing CLAUDE.md
  if [ -f "$CLAUDE_MD" ]; then
    cp "$CLAUDE_MD" "$CLAUDE_MD.bak"
    echo "     Backed up existing CLAUDE.md to CLAUDE.md.bak"
  fi
  # Append snippet
  echo "" >> "$CLAUDE_MD"
  cat "$SCRIPT_DIR/claude-md-snippet.md" >> "$CLAUDE_MD"
  echo "[4/5] Added Gate System to CLAUDE.md"
fi

# 5. Done
echo "[5/5] Installation complete!"
echo ""
echo "Usage:"
echo "  /gate           Auto-detect phase and run gate"
echo "  /gate spec      Run Spec Gate"
echo "  /gate design    Run Design Gate"
echo "  /gate code      Run Task Gate (code review)"
echo "  /gate release   Run Release Gate (code + security)"
echo "  /gate status    Show gate statuses"
echo ""
echo "To uninstall: ./uninstall.sh"
