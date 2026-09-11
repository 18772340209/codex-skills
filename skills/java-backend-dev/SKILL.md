---
name: java-backend-dev
description: Implement or modify Java and Spring Boot backend production code, including features, APIs, services, data access, integrations, and ordinary bug fixes. Do not use for review-only, diagnosis-only, test-only, SQL-analysis, or architecture-design requests.
---

# Java 后端开发

将本 Skill 作为 Java 后端工作的默认实现流程。它是执行型 Skill，不是 Java 教程。

专业任务应使用对应 Skill：仅审查请求使用 `springboot-code-review`；root cause 未知时使用 `springboot-debug`；测试是主要交付物时使用 `java-test-generator`；专门的 MySQL 分析使用 `mysql-sql-review`；系统设计决策使用 `architecture-review`。实现任务仍可包含适量的审查、诊断、测试、SQL 检查或设计推理，而无需改变主 Skill。

## 优先级

1. 用户要求高于本 Skill；
2. 除非现有项目约定明显不安全，否则它优先于通用最佳实践；
3. 优先采用能够完整解决需求的最小变更；
4. 没有具体需要时，不要引入新架构、抽象、dependency 或 infrastructure；
5. 除非实际成功执行，否则绝不能声称 compilation/test 已通过。

## 1. 修改前检查

修改代码前，检查能够确定以下信息的最少文件：

- Java 版本；
- Spring Boot/Spring Framework 版本；
- Maven 或 Gradle，以及 wrapper 是否可用；
- module 边界；
- package 和命名约定；
- Controller/Service/Repository 或 Mapper 约定；
- ORM/data access：MyBatis、MyBatis-Plus、JPA、JDBC、jOOQ 等；
- 现有 response envelope、exception handling、validation、logging、pagination、conversion、constant、enum 和 utility 模式；
- 相关 Redis/MQ/RPC/HTTP/database infrastructure；
- 受影响代码附近的现有测试。

优先从 `pom.xml`、`build.gradle*`、wrapper 文件、application configuration、代码、测试和 migration/schema 文件中获取证据。不要凭记忆推断版本。

## 2. 追踪变更范围

处理 feature 或 bug 时，编码前先追踪相关路径：

`Controller/API -> Service -> domain/business logic -> Mapper/Repository -> SQL/table`

适用时还应检查：

- 被修改方法的 caller；
- downstream call；
- scheduled job；
- MQ producer/consumer；
- cache read/write；
- transaction boundary；
- database constraint 和 index；
- test。

添加新代码之前，先搜索类似实现。

## 3. 规划最小变更

编辑前，应能在内部回答：

- 哪些行为会改变？
- 实际需要修改哪些文件？
- API contract 是否变化？
- DB schema 或 SQL 是否变化？
- cache/MQ 行为是否变化？
- 存在哪些 compatibility risk？
- 成本最低且有意义的验证是什么？

任务直接明确时，不要输出冗长的设计文档。

## 4. 默认分层原则

优先遵循项目现有分层。如果项目没有明确约定：

### Controller

- 绑定并校验请求数据；
- 只在项目规定的位置执行 authorization check；
- 委托 business logic；
- 返回项目标准 response shape；
- 不直接访问 database；
- 不嵌入多步骤业务工作流。

### Service

- 承担业务决策和 orchestration；
- 定义 transaction boundary；
- 协调 repository/mapper 与外部系统；
- 保持方法 cohesive，只有复用性或可读性确有收益时才提取。

### Repository / Mapper

- 承担 data access；
- 除非项目有意如此建模，否则不要把业务策略放进 SQL/mapper。

### DTO / VO / Entity

当边界或语义不同时使用独立类型。不要为简单操作机械地创建 DTO/VO/Command/Assembler 分层。

## 5. Java 正确性检查

检查变更代码中的：

- nullable input/return 和 NPE 风险；
- collection 是否为空及 mutation；
- `equals`/`hashCode`；
- `BigDecimal` scale、比较和 rounding；
- date/time zone 以及 inclusive/exclusive boundary；
- enum unknown value；
- numeric overflow 和 narrowing conversion；
- Optional 误用；
- resource closing；
- exception swallowing；
- mutable shared state；
- 不安全的 stream/parallelStream 使用；
- 日志中的敏感值。

当 business logic 因复杂 stream chain 而难以审计时，优先使用易读的 loop/branch。

## 6. Transaction

涉及 DB 写入时，检查：

- transaction scope 和 duration；
- Spring proxy/self-invocation 限制；
- 适用时 checked exception 的 rollback 行为；
- 跨 async/thread boundary 的调用；
- DB transaction 内部的 remote HTTP/RPC/MQ 调用；
- lock order 和 deadlock 风险；
- batch size；
- retry 行为。

不要假设 Redis 或 MQ 参与本地 DB transaction。

## 7. 并发与幂等

只有业务流程确实可能发生 race 时，才提升并发控制等级。

检查：

- duplicate submission；
- lost update；
- check-then-act race；
- MQ 重复投递；
- scheduled task 并发执行；
- optimistic/pessimistic locking 需求；
- distributed lock ownership 和 safe release；
- 作为幂等基础的 unique constraint；
- 带 expected-current-state 条件的 state transition。

如果 durable DB constraint/state transition 能更直接地解决问题，应优先于 Redis lock。

## 8. Redis

涉及 cache 变更时，检查：

- key 设计和 TTL；
- cache-aside 顺序；
- stale data window；
- delete/update failure；
- 适用时的 cache penetration、breakdown 和 avalanche 风险；
- hot key/big key；
- serialization compatibility。

在证明有需要之前，不要为查询添加 cache。

## 9. MQ

对于 Kafka/RocketMQ/RabbitMQ 等，检查：

- producer send result 处理；
- consumer 幂等；
- duplicate delivery；
- retry 和 poison/dead-letter 行为；
- ordering requirement；
- offset/ack timing；
- transaction/outbox 需求；
- backlog observability。

绝不能假设 broker-level guarantee 等同于业务 exactly-once semantics。

## 10. SQL 意识

对于修改过的查询，检查：

- predicate selectivity；
- index compatibility；
- 意外 full scan；
- N+1 或循环 query；
- pagination 正确性；
- batch operation；
- lock range；
- result cardinality 变化。

专门的 SQL performance 诊断使用 `mysql-sql-review`。

## 11. 验证

优先执行范围最窄且有用的检查：

1. 现有的 targeted unit/integration test；
2. module compilation/test；
3. 仅在实际可行且相关时执行 full project test。

如果项目提供 wrapper，应优先使用：

- Maven：`./mvnw ...` 或 `mvn ...`；
- Gradle：`./gradlew ...` 或 `gradle ...`。

如果测试无法运行，准确说明阻碍验证的原因。

## 12. 完成报告

最终工程报告应简短说明：

- 修改了什么；
- 涉及的重要文件；
- 关键理由或 tradeoff；
- 实际执行的验证及结果；
- 仍存在的风险或 manual check（如有）。

不要用通用最佳实践填充总结。
