# codex-java-skills

A practical Codex skill pack for Java / Spring Boot backend development.

## Included skills

| Skill | Purpose |
|---|---|
| `java-backend-dev` | Production-code implementation and ordinary bug fixes |
| `springboot-code-review` | Defect-focused code, diff, commit, and PR review |
| `mysql-sql-review` | Dedicated MySQL SQL, EXPLAIN, index, and locking analysis |
| `springboot-debug` | Evidence-driven diagnosis when the root cause is unknown |
| `java-test-generator` | Unit, slice, integration, and regression test creation |
| `architecture-review` | Backend architecture and distributed-system design decisions |

## Repository layout

```text
codex-java-skills/
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

## Install locally

Codex user skills normally live under `$CODEX_HOME/skills`; when `CODEX_HOME` is not set, `~/.codex/skills` is the conventional location.

### Windows PowerShell

From the repository root:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

### macOS / Linux

```bash
bash ./scripts/install.sh
```

The scripts copy all six skill folders into your Codex skills directory.

Restart/reload Codex after installation if the skills are not picked up immediately.

## Install from GitHub with Codex

After pushing this repository to GitHub, you can ask Codex:

```text
Use $skill-installer to install all skills from:
https://github.com/<YOUR_GITHUB_USER>/codex-java-skills/tree/main/skills
```

If installing one skill at a time:

```text
Use $skill-installer to install:
https://github.com/<YOUR_GITHUB_USER>/codex-java-skills/tree/main/skills/mysql-sql-review
```

For a private repository, Codex needs GitHub credentials that can read that repository.

## Example usage

```text
Use $java-backend-dev to implement this Spring Boot requirement.
```

```text
Use $springboot-code-review to review the current branch against main.
```

```text
Use $mysql-sql-review to analyze this SQL and EXPLAIN. Preserve current result semantics.
```

```text
Use $springboot-debug to investigate why this API P99 jumped from 200 ms to 3 s.
```

```text
Use $java-test-generator to add regression tests for this bug fix.
```

```text
Use $architecture-review to design order timeout cancellation for the current traffic level and a 10x growth path.
```

Codex may also select a skill automatically when its `description` matches the task.

The skills are separated by their primary deliverable: implementation, review findings, SQL analysis, root-cause diagnosis, tests, or architecture decisions. Supporting work such as adding tests during implementation does not require switching away from the primary skill.

## Recommended workflow

Keep generic engineering rules in these reusable skills. Put project-specific facts in the project repository, preferably in `AGENTS.md` or project-local instructions, for example:

- required Java version;
- exact Spring Boot version;
- package/module layout;
- company-specific response types;
- database naming rules;
- approved dependencies;
- build/test commands;
- branch/commit conventions.

Do not hard-code one company's conventions into reusable global skills.

## Versioning

Use ordinary Git tags for stable releases:

```bash
git tag -a v0.1.0 -m "Initial Java skill pack"
git push origin v0.1.0
```

Suggested approach:
- patch: wording/check improvements;
- minor: meaningful new workflow/rules;
- major: incompatible skill behavior or repository layout change.
