#!/usr/bin/env bash
set -euo pipefail

# Claude Gate - Multi-CLI Uninstallation Script
# Removes gate files from: Claude Code, Codex CLI, Gemini CLI

# ─── Parse flags ───
ALL_MODE=false
for arg in "$@"; do
  case "$arg" in
    --all|-a) ALL_MODE=true ;;
  esac
done

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${BOLD}╔══════════════════════════════════════╗${NC}"
echo -e "${BOLD}║       Claude Gate Uninstaller         ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════╝${NC}"
echo ""

# ─── Detect installed gate files ───
declare -a INSTALLED_CLIS=()
declare -a INSTALLED_NAMES=()

# Claude Code
if [ -f "$HOME/.claude/commands/gate.md" ] || [ -f "$HOME/.claude/agents/gate-keeper.md" ]; then
  INSTALLED_CLIS+=("claude")
  INSTALLED_NAMES+=("Claude Code")
fi

# Codex CLI
if [ -d "$HOME/.codex/skills/gate-spec" ] || [ -d "$HOME/.codex/skills/gate-code" ]; then
  INSTALLED_CLIS+=("codex")
  INSTALLED_NAMES+=("Codex CLI")
fi

# Gemini CLI
if [ -d "$HOME/.gemini/commands/gate" ] || [ -f "$HOME/.gemini/agents/spec-reviewer.md" ]; then
  INSTALLED_CLIS+=("gemini")
  INSTALLED_NAMES+=("Gemini CLI")
fi

if [ ${#INSTALLED_CLIS[@]} -eq 0 ]; then
  echo "No Claude Gate installations found."
  exit 0
fi

echo -e "${YELLOW}Found Claude Gate in:${NC}"
for i in "${!INSTALLED_CLIS[@]}"; do
  echo -e "  ${CYAN}[$((i+1))]${NC} ${INSTALLED_NAMES[$i]}"
done
echo ""

# ─── Interactive selection ───
declare -a SELECTED=()

if [ "$ALL_MODE" = true ]; then
  SELECTED=("${INSTALLED_CLIS[@]}")
  echo -e "Auto-selected all (--all mode)"
elif [ ${#INSTALLED_CLIS[@]} -eq 1 ]; then
  SELECTED=("${INSTALLED_CLIS[0]}")
  echo -e "Auto-selected: ${BOLD}${INSTALLED_NAMES[0]}${NC}"
else
  echo -e "${BOLD}Select targets to uninstall (space-separated numbers, or 'a' for all):${NC}"
  echo -n "> "
  read -r selection

  if [[ "$selection" == "a" || "$selection" == "A" || "$selection" == "all" ]]; then
    SELECTED=("${INSTALLED_CLIS[@]}")
  else
    for num in $selection; do
      idx=$((num - 1))
      if [ "$idx" -ge 0 ] && [ "$idx" -lt ${#INSTALLED_CLIS[@]} ]; then
        SELECTED+=("${INSTALLED_CLIS[$idx]}")
      fi
    done
  fi
fi

if [ ${#SELECTED[@]} -eq 0 ]; then
  echo -e "${RED}No targets selected. Exiting.${NC}"
  exit 1
fi

echo ""

# ═══════════════════════════════════════
# Uninstall functions
# ═══════════════════════════════════════

uninstall_claude() {
  echo -e "${BOLD}── Removing from Claude Code ──${NC}"

  local CLAUDE_DIR="$HOME/.claude"
  local AGENTS_DIR="$CLAUDE_DIR/agents"
  local COMMANDS_DIR="$CLAUDE_DIR/commands"
  local CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"

  local AGENTS=(
    "gate-keeper.md"
    "spec-reviewer.md"
    "design-reviewer.md"
    "code-reviewer.md"
    "security-reviewer.md"
  )

  # Remove agents
  local removed=0
  for agent in "${AGENTS[@]}"; do
    if [ -f "$AGENTS_DIR/$agent" ]; then
      rm "$AGENTS_DIR/$agent"
      removed=$((removed + 1))
    fi
  done
  echo -e "  ${GREEN}[1/3]${NC} Removed $removed agent(s)"

  # Remove command
  if [ -f "$COMMANDS_DIR/gate.md" ]; then
    rm "$COMMANDS_DIR/gate.md"
    echo -e "  ${GREEN}[2/3]${NC} Removed /gate command"
  else
    echo -e "  ${GREEN}[2/3]${NC} /gate command not found (skipped)"
  fi

  # Remove from CLAUDE.md
  if [ -f "$CLAUDE_MD" ] && grep -q "GATE-SYSTEM-START" "$CLAUDE_MD"; then
    if [[ "$(uname)" == "Darwin" ]]; then
      sed -i '' '/<!-- GATE-SYSTEM-START -->/,/<!-- GATE-SYSTEM-END -->/d' "$CLAUDE_MD"
      sed -i '' -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$CLAUDE_MD"
    else
      sed -i '/<!-- GATE-SYSTEM-START -->/,/<!-- GATE-SYSTEM-END -->/d' "$CLAUDE_MD"
      sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$CLAUDE_MD"
    fi
    echo -e "  ${GREEN}[3/3]${NC} Removed Gate System from CLAUDE.md"
  else
    echo -e "  ${GREEN}[3/3]${NC} No Gate System in CLAUDE.md (skipped)"
  fi
  echo ""
}

uninstall_codex() {
  echo -e "${BOLD}── Removing from Codex CLI ──${NC}"

  local CODEX_DIR="$HOME/.codex"
  local SKILLS_DIR="$CODEX_DIR/skills"

  local SKILLS=(
    "gate-spec"
    "gate-design"
    "gate-code"
    "gate-release"
  )

  # Remove skills
  local removed=0
  for skill in "${SKILLS[@]}"; do
    if [ -d "$SKILLS_DIR/$skill" ]; then
      rm -rf "$SKILLS_DIR/$skill"
      removed=$((removed + 1))
    fi
  done
  echo -e "  ${GREEN}[1/2]${NC} Removed $removed skill(s)"

  # Remove AGENTS.md (only if it's ours)
  if [ -f "$CODEX_DIR/AGENTS.md" ] && grep -q "Claude Gate" "$CODEX_DIR/AGENTS.md"; then
    rm "$CODEX_DIR/AGENTS.md"
    echo -e "  ${GREEN}[2/2]${NC} Removed AGENTS.md"
  else
    echo -e "  ${GREEN}[2/2]${NC} AGENTS.md not ours (skipped)"
  fi
  echo ""
}

uninstall_gemini() {
  echo -e "${BOLD}── Removing from Gemini CLI ──${NC}"

  local GEMINI_DIR="$HOME/.gemini"
  local COMMANDS_DIR="$GEMINI_DIR/commands"
  local AGENTS_DIR="$GEMINI_DIR/agents"

  # Remove commands
  if [ -d "$COMMANDS_DIR/gate" ]; then
    rm -rf "$COMMANDS_DIR/gate"
    echo -e "  ${GREEN}[1/2]${NC} Removed gate commands"
  else
    echo -e "  ${GREEN}[1/2]${NC} Gate commands not found (skipped)"
  fi

  # Remove agents
  local AGENTS=(
    "spec-reviewer.md"
    "design-reviewer.md"
    "code-reviewer.md"
    "security-reviewer.md"
  )
  local removed=0
  for agent in "${AGENTS[@]}"; do
    if [ -f "$AGENTS_DIR/$agent" ]; then
      rm "$AGENTS_DIR/$agent"
      removed=$((removed + 1))
    fi
  done
  echo -e "  ${GREEN}[2/2]${NC} Removed $removed agent(s)"
  echo ""
}

# ═══════════════════════════════════════
# Run uninstallations
# ═══════════════════════════════════════

for cli in "${SELECTED[@]}"; do
  case "$cli" in
    claude) uninstall_claude ;;
    codex)  uninstall_codex ;;
    gemini) uninstall_gemini ;;
  esac
done

echo -e "${GREEN}Claude Gate has been uninstalled.${NC}"
