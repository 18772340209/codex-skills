---
name: mysql-sql-review
description: Review and optimize MySQL SQL using query semantics, schema, indexes, data distribution, and execution plans. Use for dedicated SQL, EXPLAIN, index, locking, or query-rewrite analysis, not general Java implementation or broad code review.
---

# MySQL SQL 审查

只有在证明查询语义之后才能进行优化。

交付物应聚焦 MySQL 行为。当 SQL 只是较大范围 Java 变更审查的一部分时，使用 `springboot-code-review`；当主要任务是实现应用代码时，使用 `java-backend-dev`。

## 必需证据

尽可能收集：

- MySQL 版本；
- 完整 SQL；
- 表 DDL；
- 现有 index；
- 大致行数；
- 重要的数据分布和 cardinality；
- 安全时使用 `EXPLAIN`，最好使用 `EXPLAIN ANALYZE`；
- 适用时的 partition 定义；
- 具有代表性的参数规模，特别是大型 `IN` 列表。

不要臆造 selectivity。

## 工作流

### 1. 确立语义

明确记录：

- 预期结果粒度；
- join 关系（1:1、1:N、N:M）；
- 重复数据是否有意义；
- 所需的 null 行为；
- 改写是否可能改变重复记录数量。

在用 EXISTS 或 UNION 替换 JOIN 之前，先验证语义。

### 2. 阅读执行计划

检查：

- access type；
- possible key 和 chosen key；
- key length；
- rows/filtered；
- attached conditions；
- join order；
- temporary table；
- filesort；
- materialization；
- dependent subquery；
- 如果存在 `EXPLAIN ANALYZE`，检查实际行数和耗时。

不要把“使用了 index”等同于查询一定很快。

### 3. Predicate 与 index 匹配

对于每个候选 composite index：

- 先把 equality predicate 放在前面作为启发式起点，再根据实际访问模式考虑 range、排序和分组；
- 考虑 leftmost-prefix rule；
- 识别第一个限制后续 index navigation 的 range；
- 区分 index filtering 与 index lookup；
- 权衡 covering index 收益与写入、存储成本。

避免建议多个彼此重叠的 index。

### 4. JOIN 分析

检查：

- driving table 的 selectivity；
- 被探测侧 join key 的 index；
- cardinality explosion；
- predicate 是否意外把 LEFT JOIN 转换为 INNER JOIN；
- 是否使用去重掩盖错误 join。

### 5. `IN`、`EXISTS`、`UNION ALL`

不要声称其中一种永远更快。

适用方式：

- 当 optimizer 和 cardinality 表现良好时，用 `IN` 简洁表达成员判断；
- 当只关心是否存在且应避免重复倍增时，使用 `EXISTS`；
- 当独立分支有明显不同的最佳访问路径，且允许保留重复项时，使用 `UNION ALL`。

对于巨大的动态 ID/code 列表，考虑：

- temp/staging table；
- batch table；
- join 持久化的选择集合；
- 只有在检查语义和开销之后，才考虑应用侧分批。

### 6. 日期与 range predicate

对于区间重叠表达式：

`start <= :end AND end >= :start`

应认识到，两个独立的 range predicate 很难由一次 B-tree lookup 同时满足。分析：

- 哪个边界的 selectivity 更高；
- 其他 equality column 是否应放在 index 前部；
- 业务对区间长度的限制；
- 仅当该处被证明是热点时才考虑替代建模。

不要说 BETWEEN“不会使用 index”；它可以使用。

### 7. 分页

对于深分页：

- 评估 keyset/seek pagination；
- 保持确定性排序；
- 使用唯一的 tiebreaker。

### 8. 聚合与排序

检查：

- `GROUP BY`/`ORDER BY` 与 index 的匹配；
- 意外产生的大型临时结果；
- 不必要的 DISTINCT；
- 仅在语义保持正确时考虑预聚合。

### 9. Partitioning

对于 partitioned table：

- 验证 partition key predicate 是否允许 pruning；
- 检查 EXPLAIN 中的 `partitions`；
- 不要把 partitioning 当作 index 的替代品。

### 10. Locking 与写操作

对于 UPDATE/DELETE/SELECT ... FOR UPDATE：

- 识别访问的 index 和 range；
- 根据 isolation level 考虑 next-key lock/gap lock；
- 保持 lock order 一致；
- 避免锁定大量行的宽范围扫描；
- 检查 transaction 持续时间。

## 建议格式

返回：

1. **结论**——实际瓶颈或 hypothesis；
2. **证据**——执行计划和 schema 事实；
3. **语义风险**——必须保持不变的内容；
4. **建议 SQL**——仅在有充分理由改写时提供；
5. **建议 index**——准确列、顺序及理由；
6. **预期效果**——例如减少扫描行数，不要编造百分比；
7. **验证**——EXPLAIN/ANALYZE 和代表性参数测试。

证据不足时，说明缺失的哪些信息会改变结论。
