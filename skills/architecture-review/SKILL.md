---
name: architecture-review
description: Design or review Java backend and distributed-system architecture, including consistency, reliability, scaling, messaging, caching, locking, sharding, and scheduling decisions. Do not use for ordinary implementation, line-level code review, or incident diagnosis.
---

# Java Backend Architecture Review

Do not start with middleware. Start with requirements.

This skill produces system-level decisions and tradeoffs. Use `java-backend-dev` for routine code changes, `springboot-code-review` for defect-focused review of existing code, and `springboot-debug` for evidence-driven incident diagnosis.

## 1. Establish constraints

Extract or estimate only when explicitly allowed:

- business invariant;
- read/write QPS;
- peak/average ratio;
- data volume and growth;
- latency target (P95/P99);
- availability target;
- consistency requirement;
- acceptable delay;
- duplicate tolerance;
- ordering requirement;
- recovery/RTO/RPO expectations;
- team/ops complexity;
- existing infrastructure.

If exact numbers are missing, state assumptions instead of pretending.

## 2. Define invariants

Examples:
- an order cannot be paid twice;
- inventory cannot go below zero;
- settlement amount must be reproducible/auditable;
- cancellation after successful payment must not silently win;
- a message may be delivered more than once but business effect must occur once.

Architecture should protect invariants explicitly.

## 3. Start with the simplest viable design

For low/moderate scale, consider:
- DB transaction;
- unique constraints;
- conditional updates;
- scheduled scan;
- single relational DB;
- ordinary cache-aside.

Do not introduce MQ, distributed locks, sharding, or event sourcing because they sound “distributed”.

## 4. Scale-out triggers

Recommend additional machinery only with a trigger.

Examples:

### Scheduled scan -> delayed MQ/time wheel
Trigger:
- scan cost/latency grows;
- cancellation timeliness becomes stricter;
- DB polling load becomes material.

### Single DB -> read replica/sharding
Trigger:
- measured DB CPU/IO/storage/throughput limits;
- table/index size or maintenance becomes operationally problematic.

### Sync call -> MQ
Trigger:
- caller should not block;
- downstream throughput mismatch requires buffering;
- fan-out/event integration is needed;
- failure isolation/retry semantics are valuable.

## 5. Consistency model

For every write flow, define:

- source of truth;
- transaction boundary;
- idempotency key;
- state machine;
- retry behavior;
- duplicate behavior;
- timeout ambiguity;
- compensation/reconciliation;
- cache update/invalidation;
- message publish atomicity.

Use patterns where justified:
- unique key;
- compare-and-set status update;
- outbox;
- transactional message;
- reconciliation job.

## 6. MQ design

Specify:
- producer success/failure semantics;
- key/partition choice;
- consumer idempotency;
- retry policy;
- poison/dead-letter handling;
- ordering scope;
- backlog behavior;
- observability.

“Use MQ” is not a complete design.

## 7. Cache design

Specify:
- whether cache is optimization or authority;
- key/TTL;
- read/write sequence;
- stale-data tolerance;
- hot-key mitigation if needed;
- invalidation failure recovery.

Strong consistency requirements usually push critical decisions to the DB/source of truth.

## 8. Locking

Before distributed locks, ask whether one of these is enough:
- unique constraint;
- atomic DB update with expected state;
- optimistic lock/version;
- row lock.

If distributed lock is required, define:
- lock key granularity;
- lease duration/renewal;
- owner token;
- safe release;
- behavior on lock loss;
- whether fencing is required.

## 9. Capacity and performance

Tie claims to metrics:
- QPS/TPS;
- DB rows scanned;
- connection/thread pool occupancy;
- queue lag;
- cache hit rate;
- P95/P99;
- GC;
- CPU/IO/network.

Avoid arbitrary “QPS 10k means you need X”.

## 10. Failure analysis

Walk through:
- process crash before/after DB commit;
- timeout with unknown remote outcome;
- MQ duplicate;
- MQ delayed/out-of-order;
- Redis unavailable;
- DB failover;
- job rerun;
- partial batch failure.

State how the system converges back to correct state.

## 11. Observability

Define the minimum:
- success/error counters;
- latency histogram;
- backlog/lag;
- retry/dead-letter count;
- reconciliation mismatch count;
- business invariant alarms;
- correlation/order/message IDs in logs.

## 12. Recommendation format

Return:

1. Requirements/assumptions.
2. Recommended design.
3. Core data/state model.
4. Critical request/event sequence.
5. Consistency/idempotency strategy.
6. Failure and recovery behavior.
7. Capacity/scaling trigger.
8. Alternatives rejected and why.
9. Verification/load-test plan.

Prefer an evolvable simple design over a prematurely complex target-state architecture.
