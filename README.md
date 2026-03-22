# MqxForge

A long-running autonomous coding agent powered by the Claude Agent SDK. Build complete applications over multiple sessions using a two-agent pattern (initializer + coding agent). Includes a React-based UI with an Aceternity-inspired glassmorphic design for monitoring progress in real-time.

---

## Installation

### Prerequisites

| Requirement | Version | Check |
|---|---|---|
| **Python** | 3.11+ | `python3 --version` |
| **Node.js** | 20+ | `node --version` |
| **Claude Code CLI** | Latest | `claude --version` |

### One-Command Install

```bash
git clone https://github.com/mqxerror/MqxForge.git
cd MqxForge
./install.sh
```

That's it. The installer handles everything:
1. Detects Python 3.11+ (tries `python3.13`, `3.12`, `3.11`, then generic `python3`)
2. Verifies Node.js 20+ and npm
3. Creates a Python virtual environment in `venv/`
4. Installs all Python dependencies
5. Installs npm packages for the UI
6. Builds the React frontend
7. Checks for Claude CLI
8. Starts the server at `http://localhost:8888` and opens your browser

### Installer Options

```bash
./install.sh                    # Full install + start + open browser
./install.sh --no-browser       # Install + start, don't open browser
./install.sh --install-only     # Install everything, don't start server
./install.sh --dev              # Install + start in dev mode (Vite hot reload)
./install.sh --port 9999        # Use a custom port
./install.sh --host 0.0.0.0    # Allow remote access (use with caution)
```

### Installing Claude Code CLI

**macOS / Linux:**
```bash
curl -fsSL https://claude.ai/install.sh | bash
```

**Windows (PowerShell):**
```powershell
irm https://claude.ai/install.ps1 | iex
```

Then authenticate:
```bash
claude login
```

You need either a **Claude Pro/Max subscription** or an **Anthropic API key** from https://console.anthropic.com/.

---

## Quick Start

### 1. Start the server

```bash
./install.sh
```

The UI opens at `http://localhost:8888` (or next available port).

### 2. Create a project

Click **New Project** in the dropdown, choose a name and folder, then define your app using the interactive AI spec creator or by editing templates manually.

### 3. Run the agent

Hit the **Start** button. The agent will:
- **First run:** Read your spec and generate features in the database
- **Subsequent runs:** Implement features one by one, marking them as passing

### 4. Monitor progress

Watch the Kanban board update in real-time as features move from Pending → In Progress → Done.

---

## Manual Installation (Step by Step)

If you prefer to set things up manually instead of using `./install.sh`:

### Python Backend

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate        # macOS/Linux
# venv\Scripts\activate         # Windows

# Install dependencies
pip install -r requirements.txt

# Start the server
python -m uvicorn server.main:app --host localhost --port 8888
```

### React UI

```bash
cd ui
npm install
npm run build        # Production build (served by the backend)
# OR
npm run dev          # Development server with hot reload on :5173
```

### Running the Agent Directly (CLI)

```bash
source venv/bin/activate

# Standard mode
python autonomous_agent_demo.py --project-dir /path/to/my-app

# YOLO mode (skip browser testing, faster prototyping)
python autonomous_agent_demo.py --project-dir my-app --yolo

# Parallel mode (multiple agents)
python autonomous_agent_demo.py --project-dir my-app --parallel --max-concurrency 3

# Batch mode (multiple features per session)
python autonomous_agent_demo.py --project-dir my-app --batch-size 5
```

---

## How It Works

### Two-Agent Pattern

1. **Initializer Agent (First Session):** Reads your app specification, creates features in a SQLite database, sets up the project structure, and initializes git.

2. **Coding Agent (Subsequent Sessions):** Picks up where the previous session left off, implements features one by one, and marks them as passing.

### Feature Management

Features are stored in SQLite via SQLAlchemy and managed through an MCP server:
- `feature_get_stats` — Progress statistics
- `feature_claim_and_get` — Atomically claim next available feature
- `feature_mark_passing` — Mark feature complete
- `feature_mark_failing` — Mark feature as failing
- `feature_skip` — Move feature to end of queue
- `feature_add_dependency` — Add dependency between features (with cycle detection)

### Session Management

- Each session runs with a fresh context window
- Progress is persisted via SQLite database and git commits
- The agent auto-continues between sessions (3-second delay)
- Press `Ctrl+C` to pause; run again to resume

---

## Project Structure

```
MqxForge/
├── install.sh                  # One-command installer
├── BRAND.md                    # Brand guidelines for rebranding
├── bin/                        # npm CLI entry point
├── lib/cli.js                  # CLI bootstrap and setup logic
├── start.py                    # CLI menu and project management
├── start_ui.py                 # Web UI backend launcher
├── autonomous_agent_demo.py    # Agent entry point
├── agent.py                    # Agent session logic
├── client.py                   # Claude SDK client configuration
├── security.py                 # Bash command allowlist and validation
├── progress.py                 # Progress tracking utilities
├── prompts.py                  # Prompt loading utilities
├── api/
│   ├── database.py             # SQLAlchemy models (Feature table)
│   └── dependency_resolver.py  # Cycle detection (Kahn's + DFS)
├── mcp_server/
│   └── feature_mcp.py          # MCP server for feature management
├── server/
│   ├── main.py                 # FastAPI REST API server
│   ├── routers/                # API route handlers
│   └── services/               # Business logic services
├── ui/                         # React frontend
│   ├── src/
│   │   ├── App.tsx             # Main app component
│   │   ├── styles/globals.css  # Aceternity-inspired design system
│   │   ├── hooks/              # React Query, WebSocket, theme hooks
│   │   ├── components/         # UI components (Kanban, Agent, etc.)
│   │   └── lib/                # API client and types
│   ├── package.json
│   └── vite.config.ts
├── .claude/
│   ├── commands/               # Slash commands (/create-spec, etc.)
│   ├── skills/                 # Claude Code skills
│   └── templates/              # Prompt templates
├── requirements.txt            # Python dependencies (development)
├── requirements-prod.txt       # Python dependencies (production)
└── package.json                # npm package definition
```

---

## Configuration

Configuration is read from a `.env` file:

| Install method | Config file location |
|---|---|
| From source | `.env` in project root |
| npm global | `~/.autoforge/.env` |

### Vertex AI

```bash
CLAUDE_CODE_USE_VERTEX=1
CLOUD_ML_REGION=us-east5
ANTHROPIC_VERTEX_PROJECT_ID=your-gcp-project-id
```

### Alternative API Providers

Configure via the **Settings UI** (gear icon > API Provider):
- **Claude** (default), **GLM** (Zhipu AI), **Ollama** (local models), **Kimi** (Moonshot), **Custom**

### Webhook Notifications

```bash
PROGRESS_N8N_WEBHOOK_URL=https://your-n8n-instance.com/webhook/your-id
```

---

## UI Design

The UI uses an Aceternity-inspired design system:

- **Dark-first** — Defaults to dark mode with glassmorphic surfaces
- **Glassmorphism** — `backdrop-blur` + semi-transparent cards
- **Gradient accents** — Violet-to-teal gradient text and progress bars
- **Glow effects** — Subtle border glow on hover
- **Dot pattern** — Background texture
- **Inter + JetBrains Mono** — Clean typography

See `BRAND.md` for the full design token reference and rebranding guide.

---

## Timing Expectations

- **First session (initialization):** Several minutes to generate features — this is normal
- **Each coding iteration:** 5–15 minutes depending on complexity
- **Full app:** Many hours across multiple sessions

**Tip:** Target 20–50 features for a quick demo. Modify your app spec to control scope.

---

## Troubleshooting

| Issue | Fix |
|---|---|
| `Python 3.11+ not found` | Install from [python.org](https://python.org). The installer tries `python3.13`, `3.12`, `3.11` automatically |
| `venv module not available` | Debian/Ubuntu: `sudo apt install python3.XX-venv` |
| `Claude CLI not found` | Install with `curl -fsSL https://claude.ai/install.sh \| bash` |
| `Not authenticated` | Run `claude login` |
| `Port already in use` | Use `./install.sh --port 9999` or kill the existing process |
| `Hangs on first run` | Normal — the initializer is generating features. Watch for `[Tool: ...]` output |
| `Command blocked` | Security system working. Add to allowlist in `security.py` if needed |
| `Broken venv after Python upgrade` | Delete `venv/` and re-run `./install.sh` |

---

## License

This project is licensed under the GNU Affero General Public License v3.0 — see [LICENSE.md](LICENSE.md) for details.
