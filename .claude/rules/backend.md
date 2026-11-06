---
paths:
  - "src/api/**"
  - "src/db/**"
---

# Backend API & Database Conventions
- Validate all incoming payloads with Zod schemas before controller execution.
- Never run raw unparameterized SQL queries.
