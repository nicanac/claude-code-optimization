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
