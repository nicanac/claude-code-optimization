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
