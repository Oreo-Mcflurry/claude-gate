#!/usr/bin/env bash
set -euo pipefail

# Claude Gate - Multi-CLI Installation Script
# Supports: Claude Code, Codex CLI, Gemini CLI

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
echo -e "${BOLD}║        Claude Gate Installer          ║${NC}"
echo -e "${BOLD}║   4-Phase Quality Gate System         ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════╝${NC}"
echo ""

# ─── Detect installed CLIs ───
declare -a AVAILABLE_CLIS=()
declare -a AVAILABLE_NAMES=()

# Claude Code
if [ -d "$HOME/.claude" ]; then
  AVAILABLE_CLIS+=("claude")
  AVAILABLE_NAMES+=("Claude Code")
fi

# Codex CLI
if command -v codex &>/dev/null || [ -d "$HOME/.codex" ]; then
  AVAILABLE_CLIS+=("codex")
  AVAILABLE_NAMES+=("Codex CLI")
fi

# Gemini CLI
if command -v gemini &>/dev/null || [ -d "$HOME/.gemini" ]; then
  AVAILABLE_CLIS+=("gemini")
  AVAILABLE_NAMES+=("Gemini CLI")
fi

if [ ${#AVAILABLE_CLIS[@]} -eq 0 ]; then
  echo -e "${RED}No supported AI CLI tools detected.${NC}"
  echo ""
  echo "Supported tools:"
  echo "  - Claude Code  (~/.claude or 'claude' command)"
  echo "  - Codex CLI    (~/.codex or 'codex' command)"
  echo "  - Gemini CLI   (~/.gemini or 'gemini' command)"
  echo ""
  echo "Install at least one, then run this installer again."
  exit 1
fi

echo -e "${GREEN}Detected CLI tools:${NC}"
echo ""

# ─── Interactive checkbox menu ───
checkbox_menu() {
  local -a items=("$@")
  local count=${#items[@]}
  local cursor=0
  local -a toggled=()
  local total_lines=$((count + 2))
  local first_draw=true

  for ((i = 0; i < count; i++)); do
    toggled[$i]=1
  done

  tput civis 2>/dev/null || true

  _render_menu() {
    if [ "$first_draw" = true ]; then
      first_draw=false
    else
      local j
      for ((j = 0; j < total_lines; j++)); do
        tput cuu1
        tput el
      done
    fi

    echo -e "  ${BOLD}Select targets (↑↓ Move, Space Toggle, Enter Submit):${NC}"
    local i
    for ((i = 0; i < count; i++)); do
      local arrow="  "
      local box="[ ]"
      if [ "$cursor" -eq "$i" ]; then arrow="->"; fi
      if [ "${toggled[$i]}" -eq 1 ]; then box="[x]"; fi

      if [ "$cursor" -eq "$i" ]; then
        echo -e "    ${CYAN}${arrow} ${box} ${items[$i]}${NC}"
      else
        echo "    ${arrow} ${box} ${items[$i]}"
      fi
    done
    if [ "$cursor" -eq "$count" ]; then
      echo -e "    ${CYAN}-> [ Submit ]${NC}"
    else
      echo "       [ Submit ]"
    fi
  }

  _render_menu

  while true; do
    IFS= read -rsn1 key
    case "$key" in
      $'\033')
        read -rsn2 seq
        case "$seq" in
          '[A')
            if [ "$cursor" -gt 0 ]; then
              cursor=$((cursor - 1))
            fi
            ;;
          '[B')
            if [ "$cursor" -lt "$count" ]; then
              cursor=$((cursor + 1))
            fi
            ;;
        esac
        ;;
      ' ')
        if [ "$cursor" -eq "$count" ]; then
          break
        else
          if [ "${toggled[$cursor]}" -eq 1 ]; then
            toggled[$cursor]=0
          else
            toggled[$cursor]=1
          fi
        fi
        ;;
      '')
        break
        ;;
    esac
    _render_menu
  done

  tput cnorm 2>/dev/null || true

  MENU_RESULT=()
  for ((i = 0; i < count; i++)); do
    if [ "${toggled[$i]}" -eq 1 ]; then
      MENU_RESULT+=("$i")
    fi
  done
}

# ─── Selection logic ───
declare -a SELECTED=()

if [ "$ALL_MODE" = true ]; then
  SELECTED=("${AVAILABLE_CLIS[@]}")
  echo -e "  Auto-selected all (--all mode)"
elif [ ${#AVAILABLE_CLIS[@]} -eq 1 ]; then
  SELECTED=("${AVAILABLE_CLIS[0]}")
  echo -e "  Auto-selected: ${BOLD}${AVAILABLE_NAMES[0]}${NC}"
else
  checkbox_menu "${AVAILABLE_NAMES[@]}"
  for idx in "${MENU_RESULT[@]}"; do
    SELECTED+=("${AVAILABLE_CLIS[$idx]}")
  done
fi

if [ ${#SELECTED[@]} -eq 0 ]; then
  echo -e "${RED}No targets selected. Exiting.${NC}"
  exit 1
fi

echo ""
echo -e "${BLUE}Installing for:${NC}"
for cli in "${SELECTED[@]}"; do
  case "$cli" in
    claude) echo "  - Claude Code" ;;
    codex)  echo "  - Codex CLI" ;;
    gemini) echo "  - Gemini CLI" ;;
  esac
done
echo ""

# ═══════════════════════════════════════
# Install functions
# ═══════════════════════════════════════

install_claude() {
  echo -e "${BOLD}── Installing for Claude Code ──${NC}"

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

  # Copy agents
  mkdir -p "$AGENTS_DIR"
  for agent in "${AGENTS[@]}"; do
    if [ ! -f "$SCRIPT_DIR/agents/$agent" ]; then
      echo -e "  ${RED}Missing: agents/$agent${NC}"
      return 1
    fi
    cp "$SCRIPT_DIR/agents/$agent" "$AGENTS_DIR/$agent"
  done
  echo -e "  ${GREEN}[1/3]${NC} Installed ${#AGENTS[@]} agents"

  # Copy command
  mkdir -p "$COMMANDS_DIR"
  cp "$SCRIPT_DIR/commands/gate.md" "$COMMANDS_DIR/gate.md"
  echo -e "  ${GREEN}[2/3]${NC} Installed /gate command"

  # Append to CLAUDE.md
  if [ -f "$CLAUDE_MD" ] && grep -q "GATE-SYSTEM-START" "$CLAUDE_MD"; then
    echo -e "  ${GREEN}[3/3]${NC} Gate System already in CLAUDE.md (skipped)"
  else
    if [ -f "$CLAUDE_MD" ]; then
      cp "$CLAUDE_MD" "$CLAUDE_MD.bak"
    fi
    echo "" >> "$CLAUDE_MD"
    cat "$SCRIPT_DIR/claude-md-snippet.md" >> "$CLAUDE_MD"
    echo -e "  ${GREEN}[3/3]${NC} Added Gate System to CLAUDE.md"
  fi

  echo -e "  ${GREEN}Done!${NC} Use: /gate, /gate spec, /gate code, /gate release"
  echo ""
}

install_codex() {
  echo -e "${BOLD}── Installing for Codex CLI ──${NC}"

  local CODEX_DIR="$HOME/.codex"
  local SKILLS_DIR="$CODEX_DIR/skills"

  local SKILLS=(
    "gate-spec"
    "gate-design"
    "gate-code"
    "gate-release"
    "gate-status"
  )

  mkdir -p "$CODEX_DIR"

  # Copy skills
  for skill in "${SKILLS[@]}"; do
    mkdir -p "$SKILLS_DIR/$skill"
    if [ ! -f "$SCRIPT_DIR/codex/skills/$skill/SKILL.md" ]; then
      echo -e "  ${RED}Missing: codex/skills/$skill/SKILL.md${NC}"
      return 1
    fi
    cp "$SCRIPT_DIR/codex/skills/$skill/SKILL.md" "$SKILLS_DIR/$skill/SKILL.md"
  done
  echo -e "  ${GREEN}[1/2]${NC} Installed ${#SKILLS[@]} skills"

  # Copy AGENTS.md
  if [ -f "$SCRIPT_DIR/codex/AGENTS.md" ]; then
    cp "$SCRIPT_DIR/codex/AGENTS.md" "$CODEX_DIR/AGENTS.md"
    echo -e "  ${GREEN}[2/2]${NC} Installed AGENTS.md"
  else
    echo -e "  ${GREEN}[2/2]${NC} No AGENTS.md to install (skipped)"
  fi

  echo -e "  ${GREEN}Done!${NC} Use: \$gate-spec, \$gate-code, \$gate-release"
  echo ""
}

install_gemini() {
  echo -e "${BOLD}── Installing for Gemini CLI ──${NC}"

  local GEMINI_DIR="$HOME/.gemini"
  local COMMANDS_DIR="$GEMINI_DIR/commands"
  local AGENTS_DIR="$GEMINI_DIR/agents"

  local COMMANDS=(
    "spec.toml"
    "design.toml"
    "code.toml"
    "release.toml"
    "status.toml"
  )

  local AGENTS=(
    "spec-reviewer.md"
    "design-reviewer.md"
    "code-reviewer.md"
    "security-reviewer.md"
  )

  mkdir -p "$GEMINI_DIR"

  # Copy commands
  mkdir -p "$COMMANDS_DIR/gate"
  for cmd in "${COMMANDS[@]}"; do
    if [ ! -f "$SCRIPT_DIR/gemini/commands/gate/$cmd" ]; then
      echo -e "  ${RED}Missing: gemini/commands/gate/$cmd${NC}"
      return 1
    fi
    cp "$SCRIPT_DIR/gemini/commands/gate/$cmd" "$COMMANDS_DIR/gate/$cmd"
  done
  echo -e "  ${GREEN}[1/2]${NC} Installed ${#COMMANDS[@]} commands (/gate:*)"

  # Copy agents
  mkdir -p "$AGENTS_DIR"
  for agent in "${AGENTS[@]}"; do
    if [ ! -f "$SCRIPT_DIR/gemini/agents/$agent" ]; then
      echo -e "  ${RED}Missing: gemini/agents/$agent${NC}"
      return 1
    fi
    cp "$SCRIPT_DIR/gemini/agents/$agent" "$AGENTS_DIR/$agent"
  done
  echo -e "  ${GREEN}[2/2]${NC} Installed ${#AGENTS[@]} reviewer agents"

  echo -e "  ${GREEN}Done!${NC} Use: /gate:spec, /gate:code, /gate:release"
  echo ""
}

# ═══════════════════════════════════════
# Run installations
# ═══════════════════════════════════════

for cli in "${SELECTED[@]}"; do
  case "$cli" in
    claude) install_claude ;;
    codex)  install_codex ;;
    gemini) install_gemini ;;
  esac
done

echo -e "${BOLD}╔══════════════════════════════════════╗${NC}"
echo -e "${BOLD}║       Installation Complete!          ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════╝${NC}"
echo ""
echo "To uninstall: ./uninstall.sh"
