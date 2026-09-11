---
name: springboot-code-review
description: Review Java and Spring Boot code, diffs, commits, or pull requests for concrete defects. Use for review-only requests; do not trigger for implementation, incident diagnosis, dedicated MySQL analysis, test generation, or system design.
---

# Spring Boot Code Review

Review for defects first, not aesthetics.

This skill reports findings and verification gaps. Use `java-backend-dev` when the primary request is to implement fixes, and use a specialized skill when deep diagnosis, SQL analysis, test creation, or architecture design is the main deliverable.

## Review contract

- Review the requested diff/commit/PR, not unrelated legacy code.
- Read enough surrounding code to determine behavior and call context.
- Search callers/config/schema/tests when needed to prove a finding.
- Prefer a few high-confidence findings over speculative warnings.
- Do not report a generic best-practice violation without a plausible failure mode.
- Do not praise code unless the user asks for a general review summary.

## Severity

Use:

- **P0**: data loss, severe security exposure, catastrophic production failure.
- **P1**: likely production incident, money/data correctness issue, deadlock/outage, broken API.
- **P2**: meaningful bug under realistic conditions, performance/reliability degradation.
- **P3**: low-risk defect or maintainability problem likely to cause future bugs.

## Review passes

### 1. Behavioral correctness
Check:
- wrong branches/conditions;
- off-by-one/date boundary errors;
- null handling;
- partial updates;
- incorrect default values;
- duplicate/missing records;
- wrong aggregation;
- BigDecimal comparison/rounding;
- enum/status transition validity.

### 2. Spring behavior
Check:
- `@Transactional` self-invocation;
- ineffective transaction placement;
- rollback semantics;
- proxy/visibility issues;
- async + transaction interaction;
- bean lifecycle/circular dependency problems introduced by the change;
- validation actually being triggered;
- configuration/property binding compatibility.

### 3. Database
Check:
- query cardinality changes;
- N+1 queries;
- looped DB access;
- missing WHERE constraints;
- unsafe bulk update/delete;
- inconsistent read/write transaction assumptions;
- index-hostile predicates;
- long transactions;
- lock-order/deadlock risks.

Use `mysql-sql-review` for deep SQL/EXPLAIN analysis.

### 4. Concurrency/idempotency
Look for:
- check-then-insert/update races;
- duplicate request handling;
- lost update;
- optimistic-lock version ignored;
- distributed lock expiration/ownership bugs;
- scheduled task overlap;
- mutable singleton state;
- unsafe static collections;
- ThreadLocal leakage.

### 5. Redis/cache
Check:
- DB/cache ordering;
- stale data introduced by changed write path;
- inconsistent key generation;
- missing TTL where required;
- serialization/type changes;
- non-atomic multi-command assumptions.

### 6. MQ
Check:
- ack/commit before business persistence;
- missing idempotency;
- rethrow/retry semantics;
- poison message loop;
- ordering assumption;
- send failure ignored;
- DB commit vs message publish gap.

### 7. API compatibility
Check:
- changed field semantics;
- nullable -> non-null or vice versa;
- enum/value changes;
- HTTP status/response envelope changes;
- request validation behavior;
- backward compatibility for existing callers.

### 8. Security-adjacent application defects
Check only where relevant:
- authorization bypass caused by changed path;
- SQL/template injection;
- path traversal;
- unsafe deserialization;
- sensitive log output;
- tenant/data-scope omission.

## Finding quality bar

A valid finding should include:

1. Severity.
2. File and exact line/range when available.
3. What is wrong.
4. A concrete runtime scenario.
5. Why current tests may miss it, when useful.
6. Focused fix direction.

Example format:

`P1 — OrderService.java:118 — duplicate payment can pass the pre-check`

Then explain the race and recommend an atomic state transition or unique constraint.

## What not to report

Skip:
- formatting;
- import ordering;
- variable names unless misleading enough to cause misuse;
- “could use Optional/Stream”;
- hypothetical scale issues with no evidence;
- architectural rewrites unrelated to the diff.

## Final output

Order findings by severity. If no concrete issues are found, say so and mention any meaningful verification gap.
