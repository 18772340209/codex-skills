---
name: mysql-sql-review
description: Review and optimize MySQL SQL using query semantics, schema, indexes, data distribution, and execution plans. Use for dedicated SQL, EXPLAIN, index, locking, or query-rewrite analysis, not general Java implementation or broad code review.
---

# MySQL SQL Review

Optimize only after proving query semantics.

Keep the deliverable focused on MySQL behavior. Use `springboot-code-review` when SQL is only one part of a broader Java change review, or `java-backend-dev` when application-code implementation is primary.

## Required evidence

Collect as much as available:

- MySQL version.
- Full SQL.
- Table DDL.
- Existing indexes.
- approximate row counts.
- important data distributions/cardinality.
- `EXPLAIN` or preferably `EXPLAIN ANALYZE` when safe.
- partition definition if relevant.
- representative parameter sizes, especially large `IN` lists.

Do not invent selectivity.

## Workflow

### 1. Establish semantics
Write down:
- expected grain of the result;
- join relationships (1:1, 1:N, N:M);
- whether duplicates are meaningful;
- required null behavior;
- whether rewrite may change duplicate counts.

Before replacing JOIN with EXISTS or UNION, verify semantics.

### 2. Read the execution plan
Inspect:
- access type;
- possible/chosen key;
- key length;
- rows/filtered;
- attached conditions;
- join order;
- temporary table;
- filesort;
- materialization;
- dependent subqueries;
- actual rows/timing if `EXPLAIN ANALYZE` exists.

Do not treat “uses an index” as automatically fast.

### 3. Predicate/index matching
For each candidate composite index:
- equality predicates first as a heuristic, then ranges/order/grouping based on actual access pattern;
- account for the leftmost-prefix rule;
- identify first range that limits further index navigation;
- distinguish index filtering from index lookup;
- check covering-index benefit versus write/storage cost.

Avoid proposing many overlapping indexes.

### 4. JOIN analysis
Check:
- driving table selectivity;
- join key indexes on the probed side;
- cardinality explosion;
- predicates accidentally converting LEFT JOIN to INNER JOIN;
- deduplication used to hide a wrong join.

### 5. `IN`, `EXISTS`, `UNION ALL`
Do not claim one is always faster.

Use:
- `IN` for concise membership when optimizer/cardinality remains good.
- `EXISTS` when only existence matters and duplicate multiplication should be avoided.
- `UNION ALL` when independent branches have meaningfully different optimal access paths and duplicate preservation is acceptable.

For huge dynamic ID/code lists, consider:
- temp/staging table;
- batch table;
- joining a persisted selection set;
- application-side chunking only after checking semantics and overhead.

### 6. Date/range predicates
For expressions such as interval overlap:
`start <= :end AND end >= :start`

Recognize that two independent range predicates are difficult to satisfy with one B-tree lookup. Analyze:
- which bound is more selective;
- whether other equality columns should lead the index;
- business constraints on interval length;
- alternate modeling only if this is a demonstrated hotspot.

Avoid saying BETWEEN “does not use indexes”; it can.

### 7. Pagination
For deep pagination:
- evaluate keyset/seek pagination;
- preserve deterministic order;
- use a unique tiebreaker.

### 8. Aggregation/sort
Check:
- `GROUP BY`/`ORDER BY` alignment with index;
- accidental large temporary result;
- unnecessary DISTINCT;
- pre-aggregation opportunities only when semantics remain correct.

### 9. Partitioning
For partitioned tables:
- verify partition key predicates permit pruning;
- inspect `partitions` in EXPLAIN;
- do not treat partitioning as a substitute for indexes.

### 10. Locking and writes
For UPDATE/DELETE/SELECT ... FOR UPDATE:
- identify accessed index/range;
- consider next-key/gap locks by isolation level;
- keep lock order consistent;
- avoid broad scans that lock many rows;
- review transaction duration.

## Recommendation format

Return:

1. **Conclusion** — actual bottleneck/hypothesis.
2. **Evidence** — plan/schema facts.
3. **Semantic risks** — what must remain unchanged.
4. **Recommended SQL** — only when a rewrite is justified.
5. **Recommended index** — exact columns/order and rationale.
6. **Expected effect** — e.g. fewer scanned rows; do not fabricate percentages.
7. **Validation** — EXPLAIN/ANALYZE and representative parameter tests.

When evidence is insufficient, say which missing item would change the conclusion.
