---
name: java-test-generator
description: Add or improve Java and Spring Boot tests, including unit, slice, integration, and regression tests. Use when tests are the primary deliverable; do not trigger merely because an implementation or review should include verification.
---

# Java Test Generator

Tests should prove behavior, not mirror implementation.

Use `java-backend-dev` when tests accompany a production-code change, and `springboot-code-review` when the task is to assess existing tests rather than create or modify them.

## 1. Inspect the project

Determine:
- JUnit version;
- Mockito/AssertJ/Hamcrest usage;
- Spring test conventions;
- test naming/style;
- fixture/builders;
- DB test strategy;
- Testcontainers/embedded DB usage;
- CI constraints.

Match existing style before introducing libraries.

## 2. Choose the test level

Prefer the lowest level that reliably proves the requirement.

### Unit test
Use for:
- pure business rules;
- validation/branching;
- transformations;
- calculations.

### Slice test
Use when framework wiring matters:
- MVC request binding/validation/serialization;
- repository query mapping where supported.

### Integration test
Use when correctness depends on:
- real DB semantics;
- transactions;
- ORM mappings;
- Spring configuration;
- Redis/MQ contracts where test infrastructure exists.

Do not use `@SpringBootTest` for everything.

## 3. Test design

For changed behavior, cover applicable cases:

- happy path;
- null/empty input;
- minimum/maximum/boundary values;
- invalid state transition;
- duplicate/retry request;
- exception path;
- date/time boundary;
- BigDecimal scale/rounding;
- authorization/data-scope boundary where relevant.

For bug fixes, create a regression test that fails on the old behavior whenever practical.

## 4. Mockito discipline

Mock external collaborators, not the class under test.

Avoid:
- mocking value objects;
- mocking static utilities unless unavoidable;
- asserting every internal method call;
- overspecified interaction order.

Verify interactions when they are themselves important behavior, e.g. “do not publish event if DB update failed”.

## 5. Database tests

When query semantics are the risk:
- use representative rows;
- include duplicates/nulls/status combinations;
- assert exact result grain;
- test transaction/constraint behavior where relevant.

H2 is not proof of MySQL-specific behavior. Prefer the project’s real-DB/Testcontainers approach for MySQL-specific SQL if available.

## 6. Concurrency/idempotency tests

If the implementation claims to prevent duplicates/races:
- test repeated identical request;
- test stale expected-state update;
- use concurrent execution only when deterministic enough to be useful;
- prefer asserting DB unique/state-transition guarantees to timing-sensitive sleeps.

## 7. Naming

Test names should express:
`condition -> expected behavior`

Follow the project convention, e.g.:
`shouldRejectDuplicatePaymentWhenOrderAlreadyPaid`.

## 8. Execution

Run:
1. the new/modified test class;
2. relevant module tests;
3. broader tests only when justified.

Never say tests passed if only generated.

## Completion

Report:
- tests added/changed;
- behaviors covered;
- commands run and result;
- meaningful untested risk.
