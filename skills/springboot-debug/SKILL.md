---
name: springboot-debug
description: Diagnose Java and Spring Boot runtime incidents, failed startup, intermittent errors, performance regressions, resource exhaustion, and data inconsistency when the root cause is unknown. Do not use for routine implementation or review-only requests.
---

# Spring Boot 故障诊断

依据证据诊断，不要无差别修改配置。

主要交付物是有证据支持的 root cause 诊断和验证计划。如果原因已知且请求只是修改代码，使用 `java-backend-dev`；如果请求只是审查已有变更，使用 `springboot-code-review`。

## 1. 定义症状

记录：

- 准确的错误或症状；
- 首次确认发生的时间；
- 受影响的 endpoint/job/consumer；
- 影响范围：单个实例、部分实例或全部实例；
- 发生频率；
- latency、error rate 或资源的变化；
- 最近的 deployment、配置或数据变更。

将症状与推测原因分开。

## 2. 重建请求或任务路径

梳理相关路径：

`gateway -> controller -> service -> DB/cache/RPC/MQ`

对于 async processing：

`producer -> broker -> consumer -> DB/RPC -> ack/offset`

找出 timing 或 error 首次出现偏差的位置。

## 3. 证据优先级

优先使用：

1. stack trace 和 error log；
2. metrics；
3. thread dump 或 heap 证据；
4. DB process、lock 和 slow query 证据；
5. MQ/Redis/server metrics；
6. configuration；
7. code inspection。

不要仅凭 CPU 很高就推断是“GC 问题”。

## 4. 常见故障处置清单

### API 响应缓慢

检查：

- 可用时的 trace/span timing；
- slow SQL；
- DB pool wait；
- remote call timeout/retry；
- Redis latency；
- lock contention；
- thread pool queue；
- serialization 或大型 payload；
- GC pause。

### CPU 使用率高

检查：

- top process/thread；
- thread dump stack；
- hot loop、spin 或 retry storm；
- 过量的 serialization/regex；
- GC CPU；
- decompression/encryption hotspot。

### OOM / 内存增长

区分：

- Java heap；
- metaspace；
- direct memory；
- native/thread stack；
- container memory limit。

在可行时使用 heap dump/class histogram；寻找 retained ownership，而不只是数量最多的 class。

### DB connection pool 耗尽

检查：

- active/pending/idle；
- transaction 持续时间；
- connection leak；
- slow SQL；
- blocked transaction；
- 持有 DB connection 时发生的 downstream wait。

不要一开始就只通过增加 pool size“修复”问题。

### Deadlock/lock wait

收集 DB deadlock/lock 证据。将 SQL 映射回 service transaction、lock order、index 和 scan range。

### Redis timeout

检查：

- server latency；
- network；
- connection pool；
- big key/hot key；
- blocking command；
- timeout/retry amplification。

### MQ backlog

检查：

- 到达速率与消费速率；
- partition/queue 分布；
- consumer failure/retry；
- downstream bottleneck；
- 单条 message 的长 transaction；
- poison message。

### 数据不一致

重建：

- source of truth；
- 准确的写入顺序；
- transaction commit；
- cache invalidation；
- event publish/consume；
- retry/compensation；
- duplicate operation。

## 5. Hypothesis 纪律

维护一个简短的优先级列表：

- hypothesis；
- 支持证据；
- 反证；
- 成本最低的下一项观察。

快速淘汰证据不足的 hypothesis。

## 6. 修复选择

优先顺序：

- root cause 修复；
- 然后是安全止损；
- 最后才是 tuning。

增加 heap、pool、timeout 或 thread 等配置时，必须说明 workload/capacity 为什么支持这一调整。

## 7. 验证

定义：

- reproduction/test；
- 预期的 metric/log 变化；
- regression risk；
- rollback trigger；
- 如果后续 deployment，定义生产观察窗口。

## 输出

使用以下结构：

- 症状和影响范围；
- 最可能的 root cause；
- 证据；
- 仍待排除的替代 hypothesis；
- 修复方案；
- 验证方式；
- 预防性 monitoring/test。
