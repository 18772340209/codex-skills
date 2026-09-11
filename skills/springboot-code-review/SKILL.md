---
name: springboot-code-review
description: Review Java and Spring Boot code, diffs, commits, or pull requests for concrete defects. Use for review-only requests; do not trigger for implementation, incident diagnosis, dedicated MySQL analysis, test generation, or system design.
---

# Spring Boot 代码审查

优先审查缺陷，而不是审美问题。

本 Skill 交付审查发现和验证缺口。当主要请求是实现修复时，使用 `java-backend-dev`；当主要交付物是深度诊断、SQL 分析、测试创建或架构设计时，使用对应的专业 Skill。

## 审查约定

- 审查用户指定的 diff/commit/PR，不扩展到无关 legacy code；
- 阅读足够的上下文代码，以确定行为和调用关系；
- 在需要证明问题时，搜索 caller/config/schema/test；
- 宁可提供少量高置信度问题，也不要堆砌推测性警告；
- 没有可信 failure mode 时，不要报告泛化的最佳实践违规；
- 除非用户要求整体评审总结，否则不要赞美代码。

## 严重级别

使用：

- **P0**：数据丢失、严重安全暴露或灾难性生产故障；
- **P1**：很可能导致生产事故、资金或数据正确性问题、deadlock/outage 或 API 破坏；
- **P2**：在现实条件下出现的实质性 bug，或 performance/reliability 退化；
- **P3**：低风险缺陷，或很可能引发未来 bug 的 maintainability 问题。

## 审查维度

### 1. 行为正确性

检查：

- 错误分支或条件；
- off-by-one 和日期边界错误；
- null 处理；
- 部分更新；
- 错误默认值；
- 重复或缺失记录；
- 错误聚合；
- BigDecimal 比较和舍入；
- enum/status 状态转换有效性。

### 2. Spring 行为

检查：

- `@Transactional` self-invocation；
- 无效的 transaction 位置；
- rollback 语义；
- proxy/visibility 问题；
- async 与 transaction 的交互；
- 变更引入的 bean lifecycle/circular dependency 问题；
- validation 是否真正触发；
- configuration/property binding 兼容性。

### 3. Database

检查：

- query cardinality 变化；
- N+1 query；
- 循环 DB 访问；
- 缺失 WHERE 约束；
- 不安全的批量 update/delete；
- 不一致的读写 transaction 假设；
- 对 index 不友好的 predicate；
- 长 transaction；
- lock order/deadlock 风险。

深度 SQL/EXPLAIN 分析使用 `mysql-sql-review`。

### 4. 并发与幂等

查找：

- check-then-insert/update race；
- 重复请求处理；
- lost update；
- optimistic lock version 被忽略；
- distributed lock 过期或 ownership bug；
- scheduled task 重叠执行；
- mutable singleton state；
- 不安全的 static collection；
- ThreadLocal 泄漏。

### 5. Redis/cache

检查：

- DB/cache 操作顺序；
- 变更后的写路径是否引入 stale data；
- 不一致的 key 生成方式；
- 需要 TTL 的场景是否遗漏；
- serialization/type 变更；
- 把多个 command 错当作 atomic operation。

### 6. MQ

检查：

- 在业务持久化之前 ack/commit；
- 缺少幂等；
- rethrow/retry 语义；
- poison message loop；
- ordering 假设；
- 忽略 send failure；
- DB commit 与 message publish 之间的缺口。

### 7. API 兼容性

检查：

- field 语义变化；
- nullable 与 non-null 之间的变化；
- enum/value 变化；
- HTTP status/response envelope 变化；
- request validation 行为；
- 现有 caller 的 backward compatibility。

### 8. 与安全相关的应用缺陷

仅在相关时检查：

- 变更路径引起的 authorization bypass；
- SQL/template injection；
- path traversal；
- 不安全的 deserialization；
- 日志输出敏感数据；
- 遗漏 tenant/data scope。

## 审查发现的质量门槛

有效发现应包括：

1. 严重级别；
2. 可用时提供文件及准确行号或范围；
3. 问题是什么；
4. 具体 runtime 场景；
5. 有帮助时说明现有测试为何可能遗漏；
6. 聚焦的修复方向。

示例格式：

`P1 — OrderService.java:118 — duplicate payment can pass the pre-check`

随后解释 race，并建议 atomic state transition 或 unique constraint。

## 不应报告的内容

跳过：

- formatting；
- import ordering；
- variable name，除非其误导性足以引起误用；
- “可以使用 Optional/Stream”；
- 没有证据的假设性 scale 问题；
- 与当前 diff 无关的架构重写。

## 最终输出

按严重级别排序审查发现。如果没有发现具体问题，应明确说明，并指出有意义的验证缺口。
