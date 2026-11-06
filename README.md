# Claude Code Multi-Tier Architecture & Optimization Suite

Production-ready architecture, sub-agents, custom skills, and guardrails to optimize token efficiency and execution quality in [Claude Code](https://github.com/anthropics/claude-code).

---

## Architecture Overview

```
                      ┌───────────────────────────────────────┐
                      │        Main Orchestrator (Opus)        │
                      │  - Architectural planning & reasoning  │
                      │  - Prompt cache TTL: 1h               │
                      └──────────────────┬────────────────────┘
                                         │
        ┌────────────────────────────────┼────────────────────────────────┐
        │                                │                                │
        ▼                                ▼                                ▼
┌─────────────────────────┐   ┌─────────────────────────┐   ┌─────────────────────────┐
│   Explore (Haiku)       │   │  haiku-io-worker (Haiku)│   │    visual-qa (Sonnet)   │
│ - Read-only discovery   │   │ - Log parsing & regex   │   │ - Playwright / DevTools │
│ - Token ceiling: 85k    │   │ - WebFetch & scraping   │   │ - Screenshot critique   │
│ - Omit CLAUDE.md        │   │ - Token ceiling: 80k    │   │ - Foreground execution  │
└─────────────────────────┘   └─────────────────────────┘   └─────────────────────────┘
```

### Model Roles & Tiering
1. **Opus (Main Thread)**: Handles high-stakes architecture, reasoning, and planning. Never pollutes context with raw log dumps or multi-megabyte file reads.
2. **Sonnet (Implementation & QA)**: Executing code fixes, UI implementation, and visual verification via `/visual-qa`. Switch automatically with `/model opusplan`.
3. **Haiku (Sub-Agents & I/O)**: Dedicated, isolated context windows for broad symbol searches (`Explore`) and log parsing / web scraping (`haiku-io-worker`) to stay well under the 100,000-token pricing cliff.

---

## Repository Structure

```
├── .claude/
│   ├── settings.json              # Granular permissions, sub-agent routing, cache TTL, and audio hooks
│   ├── agents/
│   │   ├── Explore.md             # Haiku read-only codebase explorer (overrides default Explore)
│   │   └── haiku-io-worker.md     # High-volume log parser & web scraper
│   ├── skills/
│   │   ├── log-triage/SKILL.md    # Pre-filters logs via bash and analyzes in haiku-io-worker
│   │   ├── architect-plan/SKILL.md# Enforces 95% confidence and clarifying questions before coding
│   │   └── visual-qa/SKILL.md     # Multi-pass browser & screenshot validation loop
│   └── rules/
│       └── backend.md             # Path-scoped conventions for src/api/** and src/db/**
├── CLAUDE.md.template             # Lean 150-200 line project memory template
├── setup.sh                       # One-click provisioning script
└── README.md
```

---

## Quick Start

### 1. Run the Provisioning Script
Clone this repository or run `setup.sh` in your target project root (or `~/` for machine-global settings):

```bash
chmod +x setup.sh
./setup.sh
```

### 2. Restart & Verify
```bash
# Launch Claude Code
claude

# Confirm sub-agents are registered
/agents

# Test skills
/architect-plan "Refactor user authentication flow"
/log-triage "./logs/test-failure.log"
/visual-qa "http://localhost:3000"
```

---

## 32 Claude Code Optimization Best Practices

### Beginner Optimizations
1. **Run `/init` on Every Project**: Scans codebase and generates initial `CLAUDE.md`.
2. **Set Up a Status Line (`/st`)**: Displays active model, token cost, and context usage percentage.
3. **Use Voice Input (`/voice`)**: Dictate complex tasks directly to terminal.
4. **Keep Context Small**: Supply only specific files needed for immediate tasks.
5. **Locate Token Bloat with `/context`**: Inspect token allocation across system prompts, MCPs, and history.
6. **Compact at 60% & `/clear`**: Run `/compact` around 60% capacity specifying key schemas, and `/clear` between unrelated tasks.
7. **Always Start in Plan Mode (`Shift + Tab`)**: Research, ask questions, and plan architecture before writing files.
8. **Treat Claude Like a Junior Developer**: Frame prompts around problems to force architectural reasoning.
9. **Enforce Clarifying Questions**: Require 95% confidence on requirements before code generation.
10. **Build Self-Verification into To-Do Lists**: Require explicit validation steps (console check, screenshot) before marking tasks complete.

### Intermediate Workflow Hacks
11. **Deploy Sub-Agents for Parallel Work**: Spin up isolated context windows for tests and research.
12. **Build Custom Skills**: Define SOPs as markdown skills under `.claude/skills/`.
13. **Route Sub-Agents to Haiku**: Route bulk reading, scraping, and log parsing to Haiku (`CLAUDE_CODE_SUBAGENT_MODEL: "haiku"`).
14. **Curate `CLAUDE.md` to 150–200 Lines**: Keep project memory lean to prevent context degradation.
15. **Route `CLAUDE.md` to Dedicated Sub-Files**: Use path-scoped rules in `.claude/rules/` with YAML `paths:` frontmatter.
16. **Interrupt Early with Escape**: Stop drift immediately to avoid burning context.
17. **Aggressively Challenge Mediocre Outputs**: Reject generic solutions and save winning patterns to skills.
18. **Use `/rewind` for Quick Undos**: Revert to earlier conversational branches without losing environment setup.
19. **Set Up Notification Hooks**: Configure sound alerts (`afplay` / `paplay`) in `.claude/settings.json` on command stop.
20. **Run Multi-Pass Screenshot Feedback Loops**: Take screenshots and critique layout before finishing UI tasks.
21. **Automate Browser Testing via Chrome DevTools / Playwright**: Click, submit forms, and catch runtime console errors directly.
22. **Clone Design References**: Pass screenshots and HTML snippets from reference designs for exact styling.

### Advanced & Power-User Techniques
23. **Run Parallel Sessions with Git Worktrees**: Use `claude --worktree <name>` for conflict-free multi-feature development.
24. **Use Direct API Endpoints Over Heavy MCP Servers**: Call minimal endpoints to avoid schema bloat.
25. **Automate Continuous Checks with `/loop`**: Schedule recurring terminal checks (e.g., monitor build logs every 5m).
26. **Host Claude Code on a Remote VPS**: Keep long-running tasks active via SSH or Telegram.
27. **Control Local Sessions via Mobile Remote Control**: Monitor running tasks remotely from a mobile browser.
28. **Run Data Analysis via Terminal CLIs**: Use CLI tools (e.g. `bq`, `duckdb`) for natural-language data operations.
29. **Trigger `ultrathink` for High-Stakes Logic**: Allocate full 32,000-token reasoning budget for elusive bugs.
30. **Configure Granular Execution Permissions**: Use allow/deny lists in `settings.json` instead of `--dangerously-skip-permissions`.
31. **Deploy Agent Teams**: Coordinate multi-agent workflows with shared task lists.
32. **Install Context7 MCP for Live Documentation**: Fetch up-to-date, version-specific framework documentation on demand.

---

## License
MIT
