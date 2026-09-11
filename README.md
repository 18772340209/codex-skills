# codex-skills

一套面向 Java / Spring Boot 后端开发的实用 Codex Skill 集合。

## 包含的 Skill

| Skill | 用途 |
|---|---|
| `java-backend-dev` | 生产代码实现和常规 bug 修复 |
| `springboot-code-review` | 聚焦缺陷的 code、diff、commit 和 PR 审查 |
| `mysql-sql-review` | 专门的 MySQL SQL、EXPLAIN、index 和 locking 分析 |
| `springboot-debug` | root cause 未知时基于证据进行诊断 |
| `java-test-generator` | 创建 unit、slice、integration 和 regression test |
| `architecture-review` | 后端架构和 distributed system 设计决策 |

## 仓库结构

```text
codex-skills/
├─ README.md
├─ skills/
│  ├─ java-backend-dev/SKILL.md
│  ├─ springboot-code-review/SKILL.md
│  ├─ mysql-sql-review/SKILL.md
│  ├─ springboot-debug/SKILL.md
│  ├─ java-test-generator/SKILL.md
│  └─ architecture-review/SKILL.md
└─ scripts/
   ├─ install.ps1
   └─ install.sh
```

## 本地安装

Codex 用户 Skill 通常位于 `$CODEX_HOME/skills`；未设置 `CODEX_HOME` 时，惯用位置为 `~/.codex/skills`。

### Windows PowerShell

在仓库根目录执行：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

### macOS / Linux

```bash
bash ./scripts/install.sh
```

脚本会把全部 6 个 Skill 目录复制到 Codex skills 目录。

如果安装后没有立即识别这些 Skill，请重启或重新加载 Codex。

## 使用 Codex 从 GitHub 安装

将本仓库推送到 GitHub 后，可以这样要求 Codex：

```text
使用 $skill-installer 安装以下地址中的全部 Skill：
https://github.com/18772340209/codex-skills/tree/main/skills
```

如果一次只安装一个 Skill：

```text
使用 $skill-installer 安装：
https://github.com/18772340209/codex-skills/tree/main/skills/mysql-sql-review
```

对于 private repository，Codex 需要具备该仓库读取权限的 GitHub credential。

## 使用示例

```text
使用 $java-backend-dev 实现这个 Spring Boot 需求。
```

```text
使用 $springboot-code-review 审查当前 branch 相对于 main 的变更。
```

```text
使用 $mysql-sql-review 分析这个 SQL 和 EXPLAIN，并保持当前结果语义。
```

```text
使用 $springboot-debug 调查这个 API 的 P99 为什么从 200 ms 上升到 3 s。
```

```text
使用 $java-test-generator 为这个 bug 修复添加 regression test。
```

```text
使用 $architecture-review 为当前流量和 10 倍增长路径设计订单超时取消方案。
```

当 `description` 与任务匹配时，Codex 也可以自动选择 Skill。

这些 Skill 按主要交付物划分：代码实现、审查发现、SQL 分析、root cause 诊断、测试或架构决策。实现过程中添加测试等辅助工作，不需要切换主 Skill。

## 推荐工作方式

将通用工程规则保留在这些可复用 Skill 中。把项目特有事实放在项目仓库内，最好写入 `AGENTS.md` 或项目本地说明，例如：

- 所需 Java 版本；
- 准确的 Spring Boot 版本；
- package/module 布局；
- 公司特有的 response type；
- database 命名规则；
- 允许使用的 dependency；
- build/test 命令；
- branch/commit 约定。

不要把某一家公司的约定硬编码到可复用的全局 Skill 中。

## 版本管理

使用常规 Git tag 标记稳定版本：

```bash
git tag -a v0.1.0 -m "Initial Java skill pack"
git push origin v0.1.0
```

建议：

- patch：文字或检查项改进；
- minor：有意义的新工作流或规则；
- major：不兼容的 Skill 行为或仓库结构变更。
