#!/usr/bin/env bash
# ============================================================================
#  7nashHarness - One Command Installer
# ============================================================================
#
#  Usage:
#    ./install.sh              Install + start server (auto-open browser)
#    ./install.sh --no-browser Install + start without opening browser
#    ./install.sh --dev        Install + start in dev mode (Vite hot reload)
#    ./install.sh --install-only  Install only, don't start server
#    ./install.sh --port 9999  Use custom port
#
# ============================================================================

set -euo pipefail

# ── Colors ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# ── Globals ─────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$SCRIPT_DIR/venv"
UI_DIR="$SCRIPT_DIR/ui"
PYTHON_CMD=""
PORT=""
HOST="127.0.0.1"
NO_BROWSER=false
DEV_MODE=false
INSTALL_ONLY=false

# ── Helpers ─────────────────────────────────────────────────────────────────

info()    { echo -e "  ${CYAN}▸${RESET} $1"; }
success() { echo -e "  ${GREEN}✓${RESET} $1"; }
warn()    { echo -e "  ${YELLOW}!${RESET} $1"; }
fail()    { echo -e "\n  ${RED}✗ $1${RESET}\n"; exit 1; }

step() {
  echo ""
  echo -e "  ${BOLD}[$1/$TOTAL_STEPS]${RESET} ${BOLD}$2${RESET}"
  echo -e "  ${DIM}$(printf '%.0s─' {1..46})${RESET}"
}

banner() {
  echo ""
  echo -e "  ${BOLD}${CYAN}╔══════════════════════════════════════════╗${RESET}"
  echo -e "  ${BOLD}${CYAN}║${RESET}       ${BOLD}7nashHarness${RESET} Installer            ${BOLD}${CYAN}║${RESET}"
  echo -e "  ${BOLD}${CYAN}╚══════════════════════════════════════════╝${RESET}"
  echo ""
}

# ── Argument Parsing ────────────────────────────────────────────────────────

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --no-browser)  NO_BROWSER=true; shift ;;
      --dev)         DEV_MODE=true; shift ;;
      --install-only) INSTALL_ONLY=true; shift ;;
      --port)
        shift
        [[ $# -eq 0 ]] && fail "--port requires a value"
        PORT="$1"; shift
        ;;
      --host)
        shift
        [[ $# -eq 0 ]] && fail "--host requires a value"
        HOST="$1"; shift
        ;;
      --help|-h)
        echo "Usage: ./install.sh [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --no-browser     Don't auto-open browser"
        echo "  --dev            Dev mode with Vite hot reload"
        echo "  --install-only   Install deps only, don't start server"
        echo "  --port PORT      Custom port (default: auto from 8888)"
        echo "  --host HOST      Custom host (default: 127.0.0.1)"
        echo "  --help           Show this help"
        exit 0
        ;;
      *) fail "Unknown option: $1" ;;
    esac
  done
}

# ── Step 1: Check Python ───────────────────────────────────────────────────

check_python() {
  step 1 "Checking Python 3.11+"

  # Try versioned names first (Homebrew, pyenv, deadsnakes), then generic
  for cmd in python3.13 python3.12 python3.11 python3 python; do
    if command -v "$cmd" &>/dev/null; then
      local ver
      ver=$("$cmd" --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
      local major minor
      major=$(echo "$ver" | cut -d. -f1)
      minor=$(echo "$ver" | cut -d. -f2)

      if [[ "$major" -ge 3 && "$minor" -ge 11 ]]; then
        PYTHON_CMD="$cmd"
        success "Found $cmd $ver"
        return 0
      else
        warn "$cmd $ver found but need 3.11+"
      fi
    fi
  done

  fail "Python 3.11+ not found. Install from https://python.org"
}

# ── Step 2: Check Node.js ──────────────────────────────────────────────────

check_node() {
  step 2 "Checking Node.js 20+"

  if ! command -v node &>/dev/null; then
    fail "Node.js not found. Install from https://nodejs.org"
  fi

  local ver
  ver=$(node --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
  local major
  major=$(echo "$ver" | cut -d. -f1)

  if [[ "$major" -lt 20 ]]; then
    fail "Node.js $ver found but need 20+. Install from https://nodejs.org"
  fi

  success "Found Node.js v$ver"

  if ! command -v npm &>/dev/null; then
    fail "npm not found. Reinstall Node.js from https://nodejs.org"
  fi

  local npm_ver
  npm_ver=$(npm --version 2>&1)
  success "Found npm $npm_ver"
}

# ── Step 3: Python venv + deps ─────────────────────────────────────────────

setup_python() {
  step 3 "Setting up Python environment"

  # Create venv if missing
  if [[ ! -f "$VENV_DIR/bin/python" ]]; then
    info "Creating virtual environment..."

    # Handle incompatible venvs (e.g. from Windows)
    if [[ -d "$VENV_DIR" ]]; then
      warn "Removing incompatible venv..."
      rm -rf "$VENV_DIR"
    fi

    "$PYTHON_CMD" -m venv "$VENV_DIR" || fail "Failed to create venv. On Debian/Ubuntu: sudo apt install python3-venv"
    success "Virtual environment created"
  else
    success "Virtual environment exists"
  fi

  # Install/upgrade pip + deps
  info "Installing Python dependencies..."
  "$VENV_DIR/bin/python" -m pip install -q --upgrade pip 2>&1 | grep -v "already satisfied" || true
  "$VENV_DIR/bin/python" -m pip install -q -r "$SCRIPT_DIR/requirements.txt" 2>&1 | grep -v "already satisfied" || true
  success "Python dependencies installed"
}

# ── Step 4: npm deps ───────────────────────────────────────────────────────

setup_node() {
  step 4 "Installing npm dependencies"

  if [[ -d "$UI_DIR/node_modules" ]]; then
    # Check if package.json is newer
    if [[ "$UI_DIR/package.json" -nt "$UI_DIR/node_modules" ]]; then
      info "package.json changed, updating..."
      npm install --prefix "$UI_DIR" --silent 2>&1 | tail -3
    else
      success "npm dependencies up to date"
      return 0
    fi
  else
    info "Installing npm packages (first run, may take a moment)..."
    npm install --prefix "$UI_DIR" --silent 2>&1 | tail -3
  fi

  success "npm dependencies installed"
}

# ── Step 5: Build UI ───────────────────────────────────────────────────────

build_ui() {
  step 5 "Building UI"

  local needs_build=false

  if [[ ! -d "$UI_DIR/dist" ]]; then
    needs_build=true
  elif [[ -d "$UI_DIR/src" ]]; then
    # Check if any source file is newer than dist
    local newest_src
    newest_src=$(find "$UI_DIR/src" -type f -newer "$UI_DIR/dist" 2>/dev/null | head -1)
    if [[ -n "$newest_src" ]]; then
      needs_build=true
    fi
    # Check if index.html or config changed
    if [[ "$UI_DIR/index.html" -nt "$UI_DIR/dist/index.html" ]] 2>/dev/null; then
      needs_build=true
    fi
  fi

  if $needs_build; then
    info "Building React frontend..."
    npm run build --prefix "$UI_DIR" 2>&1 | tail -5
    success "UI built successfully"
  else
    success "UI already up to date"
  fi
}

# ── Step 6: Check Claude CLI ───────────────────────────────────────────────

check_claude() {
  step 6 "Checking Claude CLI"

  if command -v claude &>/dev/null; then
    success "Claude CLI found"
    if [[ -d "$HOME/.claude" ]]; then
      info "If not logged in, run: claude login"
    else
      warn "Claude CLI not configured — run 'claude login'"
    fi
  else
    warn "Claude CLI not found (needed for the agent)"
    info "Install from: https://claude.ai/download"
    info "Then run: claude login"
  fi
}

# ── Step 7: Start server ───────────────────────────────────────────────────

find_port() {
  if [[ -n "$PORT" ]]; then
    echo "$PORT"
    return
  fi

  for p in $(seq 8888 8907); do
    if ! lsof -iTCP:"$p" -sTCP:LISTEN &>/dev/null 2>&1; then
      echo "$p"
      return
    fi
  done

  fail "No available ports in range 8888-8907"
}

start_server() {
  local port
  port=$(find_port)

  echo ""
  echo -e "  ${BOLD}${CYAN}╔══════════════════════════════════════════╗${RESET}"
  echo -e "  ${BOLD}${CYAN}║${RESET}  ${GREEN}${BOLD}7nashHarness is ready!${RESET}                  ${BOLD}${CYAN}║${RESET}"
  echo -e "  ${BOLD}${CYAN}║${RESET}                                          ${BOLD}${CYAN}║${RESET}"
  echo -e "  ${BOLD}${CYAN}║${RESET}  ${BOLD}http://$HOST:$port${RESET}$(printf '%*s' $((24 - ${#HOST} - ${#port})) '')${BOLD}${CYAN}║${RESET}"
  echo -e "  ${BOLD}${CYAN}║${RESET}                                          ${BOLD}${CYAN}║${RESET}"
  echo -e "  ${BOLD}${CYAN}║${RESET}  ${DIM}Press Ctrl+C to stop${RESET}                    ${BOLD}${CYAN}║${RESET}"
  echo -e "  ${BOLD}${CYAN}╚══════════════════════════════════════════╝${RESET}"
  echo ""

  # Open browser
  if ! $NO_BROWSER; then
    sleep 2 &
    local sleep_pid=$!
    wait "$sleep_pid" 2>/dev/null || true

    if [[ "$(uname)" == "Darwin" ]]; then
      open "http://$HOST:$port" 2>/dev/null &
    elif command -v xdg-open &>/dev/null && [[ -n "${DISPLAY:-}" ]]; then
      xdg-open "http://$HOST:$port" 2>/dev/null &
    fi
  fi

  if $DEV_MODE; then
    info "Starting in development mode..."

    # Start FastAPI backend
    "$VENV_DIR/bin/python" -m uvicorn server.main:app \
      --host "$HOST" --port "$port" --reload &
    local backend_pid=$!

    # Start Vite dev server
    VITE_API_PORT="$port" npm run dev --prefix "$UI_DIR" &
    local frontend_pid=$!

    info "Backend PID: $backend_pid  |  Frontend PID: $frontend_pid"

    trap "kill $backend_pid $frontend_pid 2>/dev/null; exit 0" INT TERM
    wait "$backend_pid" "$frontend_pid"
  else
    # Production mode
    exec "$VENV_DIR/bin/python" -m uvicorn server.main:app \
      --host "$HOST" --port "$port"
  fi
}

# ── Main ────────────────────────────────────────────────────────────────────

main() {
  parse_args "$@"

  cd "$SCRIPT_DIR"

  if $INSTALL_ONLY; then
    TOTAL_STEPS=6
  else
    TOTAL_STEPS=6
  fi

  banner
  check_python
  check_node
  setup_python
  setup_node
  build_ui
  check_claude

  if $INSTALL_ONLY; then
    echo ""
    echo -e "  ${GREEN}${BOLD}Installation complete!${RESET}"
    echo -e "  Run ${CYAN}./install.sh${RESET} to start the server."
    echo ""
    exit 0
  fi

  start_server
}

main "$@"
