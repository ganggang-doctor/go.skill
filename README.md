# go（开工）— 科研工作流 AI 指挥中心 v1.0

> **完全自包含——clone 即用，零额外依赖。**
> 解决 DeepSeek 等非 Claude 后端无法自动触发 skill 的问题。
> 不硬编码任何 skill 名称——能力标签自动发现、匹配、编排、验收。

## 一句话

**「go 开工」** → 模糊科研意图 → 自动匹配你已安装的 skill → 编排工作流 → 执行 → 验收 → 审计。

---

## 为什么需要 go

| 痛点 | go 的解决方案 |
|------|------|
| **DeepSeek 后端**无法自动触发 skill | Hook 强制注入，每轮对话自动启动 go |
| **skill 太多**（20+）不知用哪个 | 能力标签自动发现 + 关键词匹配评分 + 用户确认优先级 |
| **提示词模糊**导致 AI 理解偏差 | 多轮追问精炼 + 阶段 1.5 用户确认（L2/L3 任务强制展示） |
| **科研幻觉**（编造引用/图注不一致/数据曲解） | 双层防幻觉：阶段 1 自动注入 C-约束 + 阶段 4b 验收工具 |
| **装新 skill 后工作流混乱** | 自动检测新 skill → 匹配能力标签 → 提议重排 |
| 每次去网页端反复改提示词 | 一站式：从意图到验收全在 Claude Code 内完成 |

---

## 安装

```bash
git clone https://github.com/ganggang-doctor/go.skill.git ~/.claude/skills/go
chmod +x ~/.claude/skills/go/scripts/scan_skills.sh
```

## 首次使用

说 **"go 开工"**，go 自动进入初始化向导（~5 分钟）：

```
go（开工）v1.0 — 首次初始化
正在扫描已安装 skill... 发现 23 个 skill，匹配到 13 个能力标签。

[data_figure] 画数据图:
  1. scipilot-figure-skill-main ⭐推荐
  2. scientific-figure-skill-main
  → 你的选择: _

配置已保存到 ~/.claude/go-config.json。
```

**推荐：配置 Hook 实现每次对话自动启动**（见 [setup_guide.md](references/setup_guide.md)）。

---

## 完整功能

### 核心流水线

```
用户: "go 开工"
    │
    ▼
阶段 1: REFINE     — 提示词精炼 + 防幻觉约束自动注入
阶段 1.5: CONFIRM  — 精炼结果确认 (L2/L3 任务)
阶段 2: MATCH      — 能力标签匹配 + Skill 评分排序
阶段 3: ORCHESTRATE — 依赖图 → 串行/并行判定 → 质量关卡 → workflow_plan
阶段 4a: EXECUTE   — 按序调用 Skill
阶段 4b: ACCEPT    — 文件层 + 内容层 + 工具层验收
阶段 4c: AUDIT     — 轻量模式 / 完整模式 (go-auditor)
```

### 能力标签系统（核心创新）

**不硬编码任何 skill 名称。** go 内置 13 个能力标签，通过关键词匹配自动发现用户已安装的 skill：

| 能力标签 | 覆盖任务 |
|---------|------|
| `data_figure` | UMAP/热图/小提琴/散点/统计图 |
| `mechanism_diagram` | 信号通路/分子机制/Graphical Abstract |
| `roadmap_diagram` | 基金路线图/Gantt/实验流程 |
| `scrna_seq` | 单细胞 QC/注释/整合/拟时序/通讯 |
| `paper_writing` | SCI/中文期刊论文写作+排版+投稿 |
| `fund_proposal` | 国自然/国社科基金申请书 |
| `literature_search` | 文献搜索/引用插入/DOI 验证 |
| `literature_review` | 系统综述/领域调研 |
| `language_polish` | 中英翻译/Nature 级润色 |
| `office_document` | Word/PPT/PDF |
| `bioinfo_debug` | 生信错误排查 |
| `web_search` | 非学术内容全网搜索 |
| `ppt_slides` | 学术 PPT/组会幻灯片 |

能力标签库可扩展——go 维护者发布新版 `capability_tags.json` 即可。

### 防幻觉双层

```
第一层 (阶段 1): 按任务类型自动注入 C-约束
  - 数据分析: 数据不支持预期方向时必须指出
  - 出图: 图注与图中数据必须一致
  - 文献: 引用必须 PubMed/DOI 可追溯
  - 论文: 不得编造 p 值/相关系数/样本量

第二层 (阶段 4b): 调用验收工具
  - VLM Figure Verification (图注-数据一致性)
  - 4-index 引用三角验证 (引用是否真实存在)
  - check_figure.py --strict (图格式/DPI/字体)
  - artifact_check + integrity_audit (论文完整性)
```

### 审计双模式

| | 轻量模式 | 完整模式 (go-auditor) |
|---|---|---|
| 适用 | L1/L2 任务 | L3 任务 (论文/标书/数据提交) |
| 默认态度 | 抽查通过即放行 | **默认 NEEDS WORK** |
| 严重度分级 | 无 | BLOCKER / MAJOR / MINOR |
| 打回协议 | 无 | 指定修复 → 重审 → 最多 3 次 |
| 审计日志 | 无 | ✅ `go-output/audit-log.md` |
| 来源 | go 内置 | 改编自 claude-orchestra (MIT) |

### 自适应更新

| 触发 | go 做什么 |
|------|------|
| 装新 skill | 自动检测 → 匹配能力标签 → 提议重排 |
| "go 重排" | 全量扫描 → 重匹配 → 用户确认 |
| 连续 2 次失败 | 提示切换备选 skill |
| "XX skill 不好用" | score -2，降低优先级 |
| "go 状态" | 显示能力→skill 映射 + 评分 |

---

## 目录结构

```
go.skill/
├── SKILL.md                       ← 主 skill（决策层）
├── README.md
├── LICENSE (MIT)
├── AGENTS.md
├── config/
│   ├── capability_tags.json       ← 13 个能力标签库
│   └── go_config_template.json    ← 用户配置模板
├── scripts/
│   ├── scan_skills.sh             ← Skill 扫描引擎
│   └── go_hook.sh                 ← Hook 注入脚本
├── skills/                        ← 内置子 skill（执行层）
│   ├── go-skill-selector/         ← 评分引擎
│   └── go-auditor/                ← 审计门 (改编自 claude-orchestra MIT)
└── references/
    └── setup_guide.md             ← 安装配置指南
```

**设计原则：主 skill 管决策（精炼/匹配/编排/验收），子 skill 管执行细节（评分算法/审计协议）。**

---

## 命令

| 命令 | 作用 |
|------|------|
| `go 开工` | 启动工作流 |
| `go 重排` | 重新扫描 skill + 确认优先级 |
| `go 状态` | 查看能力标签→skill 映射 + 评分 |
| `go 严格审计` | 强制启动完整模式审计 |
| `go 轻量审计` | 切换为轻量模式审计 |
| `go 继续` | 中断后恢复执行 |

---

## 适用场景

go 的能力标签默认面向**生物医学**研究，但流水线架构（精炼→匹配→编排→验收）是**学科无关**的。其他学科用户可以：

1. 直接使用——核心管道（精炼/匹配/编排/验收/审计）对所有学科有效
2. 扩展能力标签——编辑 `capability_tags.json` 添加自己学科的关键词

---

## 常见问题

**Q: 和 orchestrator/skill-manager 等其他调度 skill 有什么区别？**

go 不硬编码 skill 名称，不依赖任何外部框架。完全自包含——内置评分引擎、审计门、扫描脚本。clone 即用。

**Q: 只装了 go 没有其他 skill 能用吗？**

go 会提示"未检测到可匹配的 skill"，然后正常终止。go 是调度层，需要你已安装执行层的 skill。

**Q: 需要安装 claude-orchestra 吗？**

不需要。go 完全自包含。go-auditor 改编自 claude-orchestra 的 auditor agent (MIT)，已内置。

---

## 维护者

[@ganggang-doctor](https://github.com/ganggang-doctor)

## License

MIT. go-auditor 子 skill 改编自 [claude-orchestra](https://github.com/claude-orchestra) (MIT).
