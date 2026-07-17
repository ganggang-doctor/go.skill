---
name: go-skill-selector
description: >
  go (开工) 内置子 skill — 多候选 skill 评分引擎。当同一能力标签匹配到多个已安装 skill 时，
  按关键词命中数 + 用户历史评分排序，选出最优。置信度 <70% 时提示用户确认。
  不作为独立入口使用——由 go 阶段 2 自动调用。
---

# go-skill-selector — 内置 Skill 评分引擎

这是 go（开工）的内置子 skill。当 go 的阶段 2（MATCH）检测到同一能力标签下有多个候选 skill 时，自动调用此评分引擎。

## 评分算法

```
对每个候选 skill:
  score = (keywords_hit / total_keywords) × 100
  score += 用户历史评分 (来自 go-feedback.json)
  score -= 近 3 次失败 × 10

最终按 score 降序排列:
  score ≥ 80 → 高置信（自动选择，不询问用户）
  score 60–79 → 中置信（自动选择，告知备选）
  score < 60 → 低置信（列出候选，请用户选择）
```

## 输出格式

```json
{
  "capability": "data_figure",
  "top_pick": {
    "skill": "scipilot-figure-skill-main",
    "score": 85,
    "confidence": "high"
  },
  "alternatives": [
    {"skill": "scientific-figure-skill-main", "score": 72},
    {"skill": "light-figure", "score": 55}
  ],
  "action": "auto_select",
  "reason": "scipilot-figure-skill-main 命中 8/10 关键词，历史评分 +5"
}
```

## 内置评分 vs 外部 skill-selector

go 优先使用此内置评分引擎。如果用户额外安装了独立的 `skill-selector`（如 orchestra 生态中的那个），go 会检测到并优先使用外部版本（功能更丰富）。内置版本确保 go 在任何环境下都能独立运行。
