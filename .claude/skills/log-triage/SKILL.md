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
