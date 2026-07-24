# go（开工）— 科研工作流 AI 指挥中心 v1.1

> **完全自包含——clone 即用，零额外依赖。**
> 专为 DeepSeek 等非 Claude 后端设计——解决 skill 无法自动触发、子 skill 从未被发现的根本问题。
> 不硬编码任何 skill 名称——能力标签自动发现、匹配、编排、验收。

## 一句话

**「go 开工」** → 模糊科研意图 → 自动匹配你已安装的 skill → 编排工作流 → 执行 → 验收 → 审计。

---

## 为什么 DeepSeek 用户需要 go

Claude Code 的 skill 自动发现依赖模型**读 description 语义匹配**。Claude 原生模型这很强，但 DeepSeek 对中文关键词和长 description 匹配很差——导致你装了 400+ 子 skill，几乎从未被调用过。

**这不是你的 skill 没用，是 DeepSeek 根本没「看到」它们。**

| 痛点 | 根因 | go 的解决方案 |
|------|------|------|
| **skill 从不触发** | DeepSeek 语义匹配差 → 跳过 | Hook 强制注入，每轮对话无条件启动 go |
| **子 skill 从未被发现** | 模型只看顶层 skill，不搜子目录 | go 三级搜索：主 skill → 子 skill 仓库 → 才自己写 |
| **skill 太多**不知用哪个 | 30+ 顶层 + 400+ 子 skill | 能力标签自动发现 + 评分排序 + 用户确认优先级 |
| **提示词模糊**导致理解偏差 | DeepSeek 对模糊中文缺乏追问能力 | 科研三要素核查 (①数据 ②工具 ③输出) + 阶段 1.5 确认 |
| **科研幻觉**（编造引用/图注与数据不一致） | 模型默认迎合预期方向 | 双层防幻觉：阶段 1 C-约束注入 + 阶段 4b 验收工具 |
| **装新 skill 后**工作流混乱 | 无自动重排机制 | 自动检测新 skill → 匹配能力标签 → 提议重排 |
| 每次去网页端反复改提示词 | 无统一调度层 | 一站式：精炼→匹配→编排→执行→验收→审计 |

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

### 三层搜索 —— 指挥官定规则，工具箱出代码

go 匹配到主 skill 后，不会让模型自己写代码——而是先搜现成的：

```
① 先搜主 Skill 自带 scripts/references/
   → 有就直接用，不绕路

② 全仓库 bash grep（不费 LLM token）
   find ~/.claude/skills -name "SKILL.md" | xargs grep -l "关键词"
   → 返回匹配文件路径（~200 字节，bash 输出不费 token）

③ 命中多个 → go-skill-selector 评分排序 → 只读最高分 1-2 个
   关键词命中数 + 历史评分 + 能力标签匹配度
   → ~3000 token 读取最优代码文件

④ 都没有 → 才允许自己写代码
```

**为什么这很重要？** DeepSeek 不知道你硬盘上有 576 个画图子 skill——它看到规则就自己从头写代码，参数不对，报错。go 的搜索策略：全搜免费 → 评分优选 → 只读最优，不费 token 也不遗漏。

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

## Changelog

### v1.1 (2026-07-18)
- **三层搜索策略**：bash grep 全仓库搜索（免费）→ go-skill-selector 评分选最优 → 只读 1-2 个文件（~3000 token）
- **两层架构**：指挥官定规则 + 工具箱出代码，两者完全解耦
- **科研三要素核查**：阶段 1 强制逐项核查 ①数据 ②工具 ③输出，不准猜
- **阶段 1.5 精炼确认**：L2/L3 任务展示精炼结果让用户确认后再执行
- **阶段 3 编排协议 (3a-3f)**：依赖图→串并行判定→质量关卡→I/O分配→错误恢复
- **阶段 4c 审计双模式**：轻量抽查 / 完整 BLOCKER 分级 + 打回重审
- **子 Skill 全面发现铁律**：不凭空写代码，先搜 400+ 子 skill
- **DeepSeek 专版 README**：根因分析 + 7 痛点对比
- **Hook 配置说明**：强调手动步骤 + 一次性配置

### v1.0 (2026-07-16)
- 能力标签系统（13 个标签，0 硬编码）
- 4 阶段流水线 + 防幻觉双层
- 内置 go-skill-selector + go-auditor
- 轻量扫描 + 评分制 + 自适应更新
- 首次初始化向导 + 错误恢复
- MIT License

## License

MIT. go-auditor 子 skill 改编自 [claude-orchestra](https://github.com/claude-orchestra) (MIT).
