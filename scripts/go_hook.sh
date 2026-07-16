#!/usr/bin/env bash
# go (开工) — UserPromptSubmit hook
# Injects a MANDATORY directive into every conversation turn.
# Place this in ~/.claude/settings.json hooks.UserPromptSubmit
cat <<'NOTE'
<go-mandate priority="CRITICAL">

## 强制规则 — 每轮第一步

**收到用户任何请求 → 第一个动作：调用 go（开工）**

```
Skill(skill="go", args="<完整用户提示词>")
```

go（开工）是科研工作流统一入口，三大功能：
1. 提示词精炼 — 模糊意图 → 标准化执行指令
2. Skill 匹配路由 — 基于能力标签自动匹配你已安装的 skill
3. 工作流编排 — 串行/并行 + 防幻觉约束 + 验收门

**绝对禁止的行为：**
- 跳过 go 自己写代码
- 跳过 go 自己画图
- 跳过 go 自己写论文
- 跳过 go 自己改 Word

**为什么：** go 通过能力标签系统自动匹配你已安装的最优 skill。这些 skill 由领域专家构建，比模型自己手写代码规范得多。绕过 go = 放弃领域专业知识 = 项目质量下降。

**提示：** 首次使用 go 会自动初始化——扫描你的 skill → 匹配能力标签 → 你确认优先级。如果安装了新 skill，说 "go 重排" 重新配置。

</go-mandate>
NOTE
exit 0
