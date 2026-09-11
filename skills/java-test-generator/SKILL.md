---
name: java-test-generator
description: Add or improve Java and Spring Boot tests, including unit, slice, integration, and regression tests. Use when tests are the primary deliverable; do not trigger merely because an implementation or review should include verification.
---

# Java 测试生成

测试应证明行为，而不是复刻实现细节。

当测试只是生产代码变更的一部分时，使用 `java-backend-dev`；当任务是评估已有测试而非创建或修改测试时，使用 `springboot-code-review`。

## 1. 检查项目

确定：

- JUnit 版本；
- Mockito/AssertJ/Hamcrest 的使用方式；
- Spring 测试约定；
- 测试命名和风格；
- fixture/builder；
- DB 测试策略；
- Testcontainers/内嵌 DB 的使用方式；
- CI 限制。

引入新库之前，先匹配项目现有风格。

## 2. 选择测试层级

优先选择能够可靠证明需求的最低测试层级。

### Unit test

适用于：

- 纯业务规则；
- 校验和分支逻辑；
- 数据转换；
- 计算逻辑。

### Slice test

在框架装配行为很重要时使用：

- MVC 请求绑定、校验和序列化；
- 框架支持的 repository 查询映射。

### Integration test

在正确性依赖以下因素时使用：

- 真实 DB 语义；
- transaction；
- ORM 映射；
- Spring 配置；
- 已有测试基础设施支持的 Redis/MQ 契约。

不要所有场景都使用 `@SpringBootTest`。

## 3. 测试设计

对于变更行为，按需覆盖：

- 正常路径；
- null/空输入；
- 最小值、最大值和边界值；
- 非法状态转换；
- 重复请求或重试请求；
- 异常路径；
- 日期和时间边界；
- BigDecimal 精度和舍入；
- 适用时的授权和数据范围边界。

对于 bug 修复，在可行时创建一个在旧行为下会失败的 regression test。

## 4. Mockito 使用纪律

Mock 外部协作者，不要 Mock 被测类本身。

避免：

- Mock value object；
- 除非无法避免，否则不要 Mock static utility；
- 断言每一个内部方法调用；
- 过度限定交互顺序。

当交互本身就是重要行为时才验证交互，例如“DB 更新失败时不得发布 event”。

## 5. Database 测试

当查询语义是主要风险时：

- 使用具有代表性的数据行；
- 包含重复值、null 和不同状态组合；
- 断言准确的结果粒度；
- 在适用时测试 transaction 和 constraint 行为。

H2 不能证明 MySQL 特有行为。对于 MySQL 特有 SQL，如果项目已有真实 DB/Testcontainers 方案，应优先沿用。

## 6. 并发与幂等测试

如果实现声称能够避免重复或竞态：

- 测试重复的相同请求；
- 测试基于过期预期状态的更新；
- 仅在结果足够确定且有意义时执行并发测试；
- 优先断言 DB unique constraint 或状态转换保证，避免依赖时序的 sleep。

## 7. 命名

测试名称应表达：

`condition -> expected behavior`

遵循项目约定，例如：

`shouldRejectDuplicatePaymentWhenOrderAlreadyPaid`。

## 8. 执行

依次运行：

1. 新增或修改的测试类；
2. 相关模块测试；
3. 仅在有充分理由时运行更广泛的测试。

如果只是生成了测试，绝不能声称测试已通过。

## 完成说明

报告：

- 新增或修改了哪些测试；
- 覆盖了哪些行为；
- 实际执行的命令及结果；
- 仍未覆盖的实质性风险。
