#!/usr/bin/env bash
set -euo pipefail

echo "=========================================================="
echo " Provisioning Claude Code Multi-Tier Architecture & Skills"
echo "=========================================================="

# 1. Create directory hierarchy
mkdir -p .claude/agents \
         .claude/skills/log-triage \
         .claude/skills/architect-plan \
         .claude/skills/visual-qa \
         .claude/rules

echo "[+] Created .claude directory structure"

# 2. Path-scoped backend conventions
cat << 'EOF' > .claude/rules/backend.md
---
paths:
  - "src/api/**"
  - "src/db/**"
---

# Backend API & Database Conventions
- Validate all incoming payloads with Zod schemas before controller execution.
- Never run raw unparameterized SQL queries.
EOF
echo "[+] Created .claude/rules/backend.md"

# 3. Explore sub-agent (Haiku read-only reconnaissance)
cat << 'EOF' > .claude/agents/Explore.md
---
name: Explore
description: Fast, read-only codebase explorer for bulk file reading, dependency tracing, module import collection, and symbol discovery. Invoke automatically for broad searches or multi-file inspection.
model: haiku
effort: low
tools: Read, Grep, Glob
disallowedTools: Write, Edit, NotebookEdit, Bash
omitClaudeMd: true
autoCompactWindow: 85000
maxTurns: 15
---

# Role: High-speed, read-only codebase reconnaissance specialist.

1. Execute searches in parallel using Glob and Grep before reading full files.
2. Use line-offset and limit parameters on Read to extract only relevant definitions and imports.
3. Never output raw, unedited file dumps. Return a structured summary under 400 tokens with exact file paths and line numbers.
EOF
echo "[+] Created .claude/agents/Explore.md"

# 4. Haiku I/O and web scraping worker
cat << 'EOF' > .claude/agents/haiku-io-worker.md
---
name: haiku-io-worker
description: High-volume data ingestion specialist for log parsing, stack-trace extraction, bulk documentation reading, and web scraping. Delegate any task involving large log files, build outputs, JSON dumps, or external URLs to this agent.
model: haiku
effort: low
tools: Read, Grep, Glob, Bash, WebFetch
disallowedTools: Write, Edit, NotebookEdit
omitClaudeMd: true
autoCompactWindow: 80000
maxTurns: 12
---

# Role: High-throughput I/O ingestion, log parser, and web-scraping filter.

1. For logs: Use targeted Bash filtering (grep -E, awk, jq, tail -n) or Grep over reading full multi-megabyte files.
2. For web scraping: Use WebFetch to pull target URLs, strip boilerplate markup, and extract only schemas, API signatures, or error codes.
3. Output Contract: Return a concise Markdown summary (max 150 words) with exact file paths, line numbers, and 5-15 lines around critical errors.
EOF
echo "[+] Created .claude/agents/haiku-io-worker.md"

# 5. Log triage skill (forked into Haiku)
cat << 'EOF' > .claude/skills/log-triage/SKILL.md
---
name: log-triage
description: Parses application, build, or test logs to extract root-cause exceptions, failing assertions, and stack traces. Use when diagnosing test failures, runtime crashes, or CI/CD log dumps.
argument-hint: "[log-file-path]"
context: fork
agent: haiku-io-worker
model: haiku
effort: low
allowed-tools: Read, Grep, Glob, Bash
---

# Automated Log Triage
Target Log Argument: $ARGUMENTS

## Pre-Injected Error Fingerprint
!if [ -f "$0" ]; then grep -n -C 3 -iE "error|exception|fatal|fail|panic" "$0" | tail -n 120; else echo "No direct file match for $0; use Glob/Grep to locate relevant log files."; fi

## Instructions
1. Analyze the pre-injected error fingerprint above and deduplicate repeated stack traces.
2. Identify the earliest chronological failure and return a brief with: Primary Failure Signature, Origin Location (file/line), Causal Chain (2-3 sentences), and 1-3 Recommended Files for Opus to inspect.
EOF
echo "[+] Created .claude/skills/log-triage/SKILL.md"

# 6. Architect plan skill (Opus confidence gate)
cat << 'EOF' > .claude/skills/architect-plan/SKILL.md
---
name: architect-plan
description: Enforces rigorous architectural planning and clarifying questions before code implementation. Invoke at the start of any complex feature or refactor.
argument-hint: "[feature-or-problem-description]"
model: opus
effort: high
allowed-tools: Read, Grep, Glob
---

# Architectural Planning Protocol
Problem Statement: $ARGUMENTS

1. Do not write or edit any source files. Delegate broad file discovery to the Explore sub-agent.
2. Continuously ask clarifying questions until you reach 95% confidence on edge cases, schemas, and architectural trade-offs.
3. Once confirmed, present a step-by-step implementation plan with explicit self-verification tasks for user approval.
EOF
echo "[+] Created .claude/skills/architect-plan/SKILL.md"

# 7. Visual QA skill (Sonnet frontend self-verification)
cat << 'EOF' > .claude/skills/visual-qa/SKILL.md
---
name: visual-qa
description: Runs multi-pass browser testing, console error checks, and screenshot layout verification before marking UI tasks complete.
argument-hint: "[local-url-or-route]"
context: fork
background: false
model: sonnet
allowed-tools: Read, Edit, Write, Bash
---

# Visual & Console Self-Verification Loop
Target URL: $ARGUMENTS

1. Launch the target route via Playwright CLI or Chrome DevTools and inspect the console and network logs for runtime errors.
2. Capture a screenshot, critique visual alignment and spacing, and apply CSS/component corrections until zero console or layout errors remain.
EOF
echo "[+] Created .claude/skills/visual-qa/SKILL.md"

# 8. Claude configuration, guardrails, and hooks
cat << 'EOF' > .claude/settings.json
{
  "model": "opus",
  "env": {
    "CLAUDE_CODE_SUBAGENT_MODEL": "haiku",
    "CLAUDE_CODE_PROMPT_CACHE_TTL": "1h",
    "CLAUDE_CODE_SUBAGENT_PROMPT_CACHE_TTL": "5m"
  },
  "permissions": {
    "allow": [
      "Read",
      "Grep",
      "Glob",
      "Bash(npm run test*)",
      "Bash(npm run lint*)",
      "Bash(git status*)",
      "Bash(git diff*)"
    ],
    "deny": [
      "Agent(model:opus)",
      "Agent(model:fable)",
      "Bash(rm -rf *)",
      "Bash(git push --force*)"
    ]
  },
  "hooks": {
    "SessionStart": [
      {
        "matcher": "compact",
        "hooks": [
          {
            "type": "command",
            "command": "echo 'POST-COMPACTION REMINDER: Main thread runs on Opus; delegate all log parsing, bulk reading, and scraping to haiku-io-worker or Explore (Haiku). Keep Haiku sub-agents below 85K tokens. Run /visual-qa before marking UI tasks complete.'"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "afplay /System/Library/Sounds/Glass.aiff 2>/dev/null || paplay /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null || true"
          }
        ]
      }
    ]
  }
}
EOF
echo "[+] Created .claude/settings.json"

echo "=========================================================="
echo " Setup complete! Next steps:"
echo " 1. Start Claude Code: claude"
echo " 2. Check agents: /agents"
echo " 3. Run /init to scan your codebase (keep CLAUDE.md < 200 lines)"
echo " 4. Run /st to activate the live token and context dashboard"
echo "=========================================================="
