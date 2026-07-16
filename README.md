# go（开工）— 科研工作流 AI 指挥中心 v1.0

> 解决 DeepSeek 等非 Claude 后端无法自动触发 skill 的问题。
> 不硬编码任何 skill 名称——自动发现、自动匹配、自动编排、自动验收。

## 一句话

**「go 开工」** — 模糊科研意图 → 自动匹配你已安装的 skill → 编排工作流 → 执行 → 验收。

## 安装

```bash
# 方式 1: 克隆到 Claude Code skills 目录
git clone https://github.com/<your-username>/go-skill.git ~/.claude/skills/go

# 方式 2: npx skills add (如果已发布到 skills.sh)
npx skills add <your-username>/go-skill
```

## 首次使用

安装后第一次说 **"go 开工"**，go 会自动进入初始化向导：

```
go（开工）v1.0 — 首次初始化

正在扫描已安装 skill... 发现 23 个 skill，匹配到 13 个能力标签。

[data_figure] 画数据图:
  1. scipilot-figure-skill-main ⭐推荐
  2. scientific-figure-skill-main
  → 你的选择: _
```

确认后配置保存到 `~/.claude/go-config.json`，以后直接用。

## 核心功能

| 功能 | 说明 |
|------|------|
| **意图精炼** | 模糊中文 → 标准化 Q/A/P/C/O/S 指令，多轮追问直到置信度 ≥95% |
| **Skill 自动发现** | 扫描所有已安装 skill，基于能力标签自动匹配（不硬编码 skill 名） |
| **防幻觉约束** | 按任务类型自动注入防幻觉规则（数据/引用/图注/论文） |
| **工作流编排** | 串行/并行 + 质量关卡 + 验收门 |
| **自适应更新** | 安装新 skill 自动检测 → 提议重排；工作流失败 → 提示优化 |

## 触发词

说 **"go"** / **"开工"** / **"开始"** / **"干活"** / **"启动"** 即可激活。

## 推荐 Hook 配置

为获得最佳体验（每轮自动强制启动），在 `~/.claude/settings.json` 中添加：

```json
{
  "hooks": {
    "UserPromptSubmit": [{
      "hooks": [{
        "type": "command",
        "command": "bash ~/.claude/skills/go/scripts/go_hook.sh"
      }]
    }]
  }
}
```

详见 [references/setup_guide.md](references/setup_guide.md)。

## 命令

| 命令 | 作用 |
|------|------|
| `go 开工` | 启动工作流 |
| `go 重排` | 重新扫描 skill 并重新配置优先级 |
| `go 状态` | 查看当前能力标签→skill 映射 |

## 为什么需要 go

1. **DeepSeek / 非 Claude 后端** 无法自动触发 skill → go 通过 hook 强制注入
2. **skill 太多**（20+）不知该用哪个 → go 自动匹配能力标签
3. **提示词模糊** 导致 AI 理解偏差 → go 多轮追问精炼
4. **科研幻觉**（编造引用/图注与数据不一致） → go 双层防幻觉
5. **每次去网页端改提示词很累** → go 一站式调度

## 架构

```
能力标签库 (capability_tags.json) ← go 维护者发布
        │
        ▼
用户安装 skill → go 启动扫描 → 匹配能力标签 → 用户确认优先级 → go-config.json
        │
        ▼
用户说 "go 开工" → 意图解析 → 查 go-config → 匹配最佳 skill → 编排 → 执行 → 验收
        │
     安装新 skill
        │
        ▼
go 下次启动 → 检测差异 → 评估 → 提议更新 → 用户确认 → go-config.json 更新
```

## 维护者

[@your-github-username](https://github.com/your-github-username)

## License

MIT
