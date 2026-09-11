---
name: springboot-debug
description: Diagnose Java and Spring Boot runtime incidents, failed startup, intermittent errors, performance regressions, resource exhaustion, and data inconsistency when the root cause is unknown. Do not use for routine implementation or review-only requests.
---

# Spring Boot Debugging

Diagnose from evidence. Do not shotgun-change configuration.

The primary deliverable is a supported root-cause diagnosis and verification plan. If the cause is already known and the request is simply to change code, use `java-backend-dev`; if the request is only to review an existing change, use `springboot-code-review`.

## 1. Define the symptom

Capture:
- exact error/symptom;
- first known occurrence;
- affected endpoint/job/consumer;
- scope: one instance, subset, or all;
- frequency;
- latency/error-rate/resource change;
- recent deployments/config/data changes.

Separate symptom from suspected cause.

## 2. Reconstruct the request/job path

Map the relevant path:

`gateway -> controller -> service -> DB/cache/RPC/MQ`

For async processing:
`producer -> broker -> consumer -> DB/RPC -> ack/offset`

Identify where timing/error first diverges.

## 3. Evidence hierarchy

Prefer:
1. stack trace/error logs;
2. metrics;
3. thread dump / heap evidence;
4. DB process/lock/slow-query evidence;
5. MQ/Redis/server metrics;
6. configuration;
7. code inspection.

Do not infer “GC problem” merely from high CPU.

## 4. Common incident playbooks

### Slow API
Check:
- trace/span timing if available;
- slow SQL;
- DB pool wait;
- remote call timeout/retry;
- Redis latency;
- lock contention;
- thread pool queue;
- serialization/large payload;
- GC pauses.

### High CPU
Check:
- top process/thread;
- thread dump stacks;
- hot loops/spin/retry storms;
- excessive serialization/regex;
- GC CPU;
- decompression/encryption hotspots.

### OOM / memory growth
Distinguish:
- Java heap;
- metaspace;
- direct memory;
- native/thread stacks;
- container memory limit.

Use heap dump/class histogram where practical; look for retained ownership, not just biggest class count.

### DB connection pool exhaustion
Check:
- active/pending/idle;
- transaction duration;
- connection leaks;
- slow SQL;
- blocked transactions;
- downstream waits occurring while holding DB connections.

Do not “fix” first by only increasing pool size.

### Deadlock/lock wait
Collect DB deadlock/lock evidence. Map SQL back to service transactions, lock order, indexes, and scan range.

### Redis timeout
Check:
- server latency;
- network;
- connection pool;
- big/hot keys;
- blocking commands;
- timeout/retry amplification.

### MQ backlog
Check:
- arrival vs consume rate;
- partition/queue distribution;
- consumer failures/retries;
- downstream bottleneck;
- long per-message transaction;
- poison messages.

### Data inconsistency
Reconstruct:
- source of truth;
- exact write sequence;
- transaction commit;
- cache invalidation;
- event publish/consume;
- retry/compensation;
- duplicate operations.

## 5. Hypothesis discipline

Maintain a short ranked list:

- hypothesis;
- supporting evidence;
- contradicting evidence;
- cheapest next observation.

Kill weak hypotheses quickly.

## 6. Fix selection

Prefer:
- root-cause fix;
- then safe containment;
- then tuning.

Configuration increases (heap, pool, timeout, threads) require an explanation of why workload/capacity warrants them.

## 7. Verification

Define:
- reproduction/test;
- expected metric/log change;
- regression risk;
- rollback trigger;
- production observation window if deployment follows.

## Output

Use this structure:

- Symptom and blast radius
- Most likely root cause
- Evidence
- Alternative hypotheses still open
- Fix
- Verification
- Preventive monitoring/test
