# go (开工) — 科研工作流 AI 指挥中心

## Purpose

`go` is a universal research workflow orchestrator for Claude Code. It does NOT hardcode any skill names. Instead, it uses a built-in capability tag system to auto-discover, match, and rank any user's installed skills.

## Activation

Invoke via `Skill(skill="go", args="<user's full prompt>")`. Trigger keywords: go, 开工, 开始, 干活, 启动.

## Key Innovation: Capability Tag System

Instead of "画图 → scipilot-figure", go works like this:

```
intent: "画论文数据图"
  → capability tag: data_figure
  → scan user's installed skills for keywords match
  → rank by score
  → present top matches to user for confirmation (first time)
  → use user's confirmed choice from go-config.json (subsequent times)
```

This means go works for ANY user regardless of what skills they have installed.

## Self-Updating

- Detects new skills on startup → proposes re-ranking
- Detects consecutive failures in same capability → suggests trying alternatives
- User can say "go 重排" to fully rescan and reconfigure

## Pipeline

1. REFINE — Intent parsing + anti-hallucination constraint injection
2. MATCH — Capability tag matching + skill selection
3. ORCHESTRATE — Workflow sequencing (serial/parallel)
4. EXECUTE — Execution (4a) → Acceptance (4b) → Audit (4c)

## See Also

- Full spec: [SKILL.md](SKILL.md)
- Capability tags: [config/capability_tags.json](config/capability_tags.json)
- User guide: [references/user_guide.md](references/user_guide.md)
