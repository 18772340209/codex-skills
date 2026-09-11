---
name: java-backend-dev
description: Implement or modify Java and Spring Boot backend production code, including features, APIs, services, data access, integrations, and ordinary bug fixes. Do not use for review-only, diagnosis-only, test-only, SQL-analysis, or architecture-design requests.
---

# Java Backend Development

Use this as the default implementation workflow for Java backend work. It is an execution skill, not a Java tutorial.

For specialized work, use `springboot-code-review` for review-only requests, `springboot-debug` when the root cause is unknown, `java-test-generator` when tests are the primary deliverable, `mysql-sql-review` for dedicated MySQL analysis, and `architecture-review` for system-design decisions. Implementation may still include proportionate review, debugging, tests, SQL checks, or design reasoning without changing the primary skill.

## Priorities

1. User requirements override this skill.
2. Existing project conventions beat generic best practices unless they are clearly unsafe.
3. Prefer the smallest change that fully solves the requirement.
4. Do not introduce architecture, abstractions, dependencies, or infrastructure without a concrete need.
5. Never claim compilation/tests passed unless they were actually executed successfully.

## 1. Inspect before editing

Before changing code, inspect the minimum files needed to establish:

- Java version.
- Spring Boot/Spring Framework version.
- Maven or Gradle and wrapper availability.
- Module boundaries.
- Package and naming conventions.
- Controller / Service / Repository or Mapper conventions.
- ORM/data access: MyBatis, MyBatis-Plus, JPA, JDBC, jOOQ, etc.
- Existing response envelope, exception handling, validation, logging, pagination, conversion, constants, enums, and utility patterns.
- Relevant Redis/MQ/RPC/HTTP/database infrastructure.
- Existing tests around the affected code.

Prefer evidence from `pom.xml`, `build.gradle*`, wrapper files, application configuration, code, tests, and migration/schema files. Do not infer versions from memory.

## 2. Trace the change surface

For a feature or bug, trace the relevant path before coding:

`Controller/API -> Service -> domain/business logic -> Mapper/Repository -> SQL/table`

Also inspect, when relevant:

- callers of the modified method;
- downstream calls;
- scheduled jobs;
- MQ producers/consumers;
- cache reads/writes;
- transaction boundaries;
- database constraints and indexes;
- tests.

Search for similar implementations before adding new code.

## 3. Plan a minimal change

Before editing, be able to answer internally:

- What behavior changes?
- Which files actually need modification?
- Does an API contract change?
- Does a DB schema or SQL change?
- Does cache/MQ behavior change?
- What compatibility risk exists?
- What is the cheapest meaningful verification?

If the task is straightforward, do not produce a long design document.

## 4. Layering defaults

Follow existing project layering first. If the project has no clear convention:

### Controller
- Bind and validate request data.
- Perform authorization checks only where the project places them.
- Delegate business logic.
- Return the project's standard response shape.
- Do not access the database directly.
- Do not embed multi-step business workflows.

### Service
- Own business decisions and orchestration.
- Define transaction boundaries.
- Coordinate repositories/mappers and external systems.
- Keep methods cohesive; extract only when reuse/readability justifies it.

### Repository / Mapper
- Own data access.
- Keep business policy out of SQL/mappers unless the project intentionally models it there.

### DTO / VO / Entity
Use separate types when boundaries or semantics differ. Do not create DTO/VO/Command/Assembler layers mechanically for trivial operations.

## 5. Java correctness checks

Check changed code for:

- nullable inputs/returns and NPE risk;
- collection emptiness and mutation;
- `equals`/`hashCode`;
- `BigDecimal` scale, comparison, rounding;
- date/time zones and inclusive/exclusive boundaries;
- enum unknown values;
- numeric overflow and narrowing conversion;
- Optional misuse;
- resource closing;
- exception swallowing;
- mutable shared state;
- unsafe stream/parallelStream use;
- sensitive values in logs.

Prefer readable loops/branches over clever stream chains when business logic becomes harder to audit.

## 6. Transactions

When DB writes are involved, inspect:

- transaction scope and duration;
- Spring proxy/self-invocation limitations;
- checked exception rollback behavior where relevant;
- calls crossing async/thread boundaries;
- remote HTTP/RPC/MQ calls inside DB transactions;
- lock order and deadlock risk;
- batch size;
- retry behavior.

Do not assume Redis or MQ participates in a local DB transaction.

## 7. Concurrency and idempotency

Only elevate concurrency controls when the business flow can actually race.

Check for:

- duplicate submission;
- lost update;
- check-then-act races;
- repeated MQ delivery;
- concurrent scheduled execution;
- optimistic/pessimistic locking needs;
- distributed lock ownership and safe release;
- unique constraints as an idempotency primitive;
- state transitions with expected-current-state conditions.

Prefer durable DB constraints/state transitions over Redis locks when they solve the problem more directly.

## 8. Redis

When cache changes are involved, inspect:

- key design and TTL;
- cache-aside ordering;
- stale data windows;
- deletion/update failure;
- penetration, breakdown, avalanche risks when applicable;
- hot/big keys;
- serialization compatibility.

Do not add cache for a query until there is a demonstrated reason.

## 9. MQ

For Kafka/RocketMQ/RabbitMQ/etc., check:

- producer send result handling;
- consumer idempotency;
- duplicate delivery;
- retry and poison/dead-letter behavior;
- ordering requirements;
- offset/ack timing;
- transaction/outbox needs;
- backlog observability.

Never assume broker-level guarantees equal business exactly-once semantics.

## 10. SQL awareness

For modified queries, inspect:

- predicate selectivity;
- index compatibility;
- accidental full scans;
- N+1 or looped queries;
- pagination correctness;
- batch operations;
- lock range;
- result cardinality changes.

For dedicated SQL performance diagnosis, use `mysql-sql-review`.

## 11. Verification

Prefer the narrowest useful checks first:

1. Existing targeted unit/integration tests.
2. Module compilation/test.
3. Full project test only if practical and relevant.

Use the project's wrapper when present:
- Maven: `./mvnw ...` or `mvn ...`
- Gradle: `./gradlew ...` or `gradle ...`

If tests cannot run, state exactly what prevented verification.

## 12. Completion report

Keep the final engineering report short:

- What changed.
- Important files touched.
- Key reasoning/tradeoff.
- Verification actually run and result.
- Remaining risk/manual check, if any.

Do not pad the summary with generic best practices.
