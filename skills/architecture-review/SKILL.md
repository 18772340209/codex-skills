---
name: architecture-review
description: Design or review Java backend and distributed-system architecture, including consistency, reliability, scaling, messaging, caching, locking, sharding, and scheduling decisions. Do not use for ordinary implementation, line-level code review, or incident diagnosis.
---

# Java 后端架构评审

不要从 middleware 开始，应从需求开始。

本 Skill 产出系统级决策与取舍。日常代码变更使用 `java-backend-dev`，针对已有代码的缺陷审查使用 `springboot-code-review`，基于证据的故障诊断使用 `springboot-debug`。

## 1. 确立约束

提取以下信息；只有在明确允许时才能估算：

- business invariant；
- 读写 QPS；
- peak/average ratio；
- 数据量和增长速度；
- latency 目标（P95/P99）；
- availability 目标；
- consistency 要求；
- 可接受延迟；
- 对重复的容忍度；
- ordering 要求；
- recovery/RTO/RPO 预期；
- 团队与 ops 复杂度；
- 现有 infrastructure。

缺少准确数字时，明确说明假设，不要伪装成已知事实。

## 2. 定义 invariant

示例：

- 一个订单不能被支付两次；
- 库存不能低于零；
- 结算金额必须可复现、可审计；
- 支付成功后，取消操作不能静默覆盖支付结果；
- message 可以投递多次，但业务效果只能发生一次。

架构应显式保护 invariant。

## 3. 从最简单的可行设计开始

对于低到中等规模，考虑：

- DB transaction；
- unique constraint；
- conditional update；
- scheduled scan；
- 单个 relational DB；
- 常规 cache-aside。

不要仅仅因为 MQ、distributed lock、sharding 或 event sourcing 听起来“分布式”就引入它们。

## 4. Scale-out 触发条件

只有存在明确触发条件时才建议增加机制。

示例：

### Scheduled scan -> delayed MQ/time wheel

触发条件：

- scan 成本或 latency 增长；
- 取消及时性要求变得更严格；
- DB polling load 已不可忽略。

### Single DB -> read replica/sharding

触发条件：

- 实测 DB CPU/IO/storage/throughput 接近限制；
- table/index 规模或维护已经带来运维问题。

### Sync call -> MQ

触发条件：

- caller 不应阻塞；
- downstream throughput 不匹配，需要 buffering；
- 需要 fan-out/event integration；
- failure isolation/retry 语义有明确价值。

## 5. Consistency model

对每条写入流程定义：

- source of truth；
- transaction boundary；
- idempotency key；
- state machine；
- retry 行为；
- duplicate 行为；
- timeout ambiguity；
- compensation/reconciliation；
- cache update/invalidation；
- message publish atomicity。

在有充分理由时使用：

- unique key；
- compare-and-set status update；
- outbox；
- transactional message；
- reconciliation job。

## 6. MQ 设计

明确：

- producer success/failure 语义；
- key/partition 选择；
- consumer 幂等；
- retry policy；
- poison/dead-letter 处理；
- ordering 范围；
- backlog 行为；
- observability。

“使用 MQ”不是完整设计。

## 7. Cache 设计

明确：

- cache 是优化手段还是权威数据源；
- key/TTL；
- 读写顺序；
- stale data 容忍度；
- 需要时的 hot key 缓解方案；
- invalidation failure 恢复方式。

强一致性要求通常意味着关键决策必须由 DB/source of truth 承担。

## 8. Locking

使用 distributed lock 之前，先判断以下方式是否已经足够：

- unique constraint；
- 带预期状态的 atomic DB update；
- optimistic lock/version；
- row lock。

如果必须使用 distributed lock，定义：

- lock key 粒度；
- lease duration/renewal；
- owner token；
- safe release；
- lock 丢失后的行为；
- 是否需要 fencing。

## 9. Capacity 与 performance

所有判断都应绑定 metrics：

- QPS/TPS；
- DB rows scanned；
- connection/thread pool occupancy；
- queue lag；
- cache hit rate；
- P95/P99；
- GC；
- CPU/IO/network。

避免武断地声称“QPS 达到 10k 就需要 X”。

## 10. Failure analysis

逐一分析：

- DB commit 前后发生 process crash；
- timeout 且 remote outcome 未知；
- MQ duplicate；
- MQ delayed/out-of-order；
- Redis 不可用；
- DB failover；
- job rerun；
- partial batch failure。

说明系统如何最终收敛回正确状态。

## 11. Observability

定义最低要求：

- success/error counter；
- latency histogram；
- backlog/lag；
- retry/dead-letter count；
- reconciliation mismatch count；
- business invariant alarm；
- 日志中的 correlation/order/message ID。

## 12. 建议格式

返回：

1. 需求和假设；
2. 推荐设计；
3. 核心数据和 state model；
4. 关键 request/event sequence；
5. consistency/idempotency 策略；
6. failure 和 recovery 行为；
7. capacity/scaling 触发条件；
8. 被否决的替代方案及原因；
9. verification/load-test 计划。

优先选择可演进的简单设计，而不是过早构建复杂的目标态架构。
