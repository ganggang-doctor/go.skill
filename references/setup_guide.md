# go（开工）安装与配置指南

## 1. 安装

```bash
git clone https://github.com/ganggang-doctor/go.skill.git ~/.claude/skills/go
chmod +x ~/.claude/skills/go/scripts/scan_skills.sh
```

## 2. 首次启动

在 Claude Code 中说 **"go 开工"**，go 自动进入初始化向导：

1. 扫描所有已安装 skill
2. 匹配内置能力标签
3. 对每个匹配到多个 skill 的能力标签，询问你的优先级选择
4. 写入 `~/.claude/go-config.json`

**首次初始化约需 5 分钟，之后每次直接使用。**

## 3. 推荐：配置 Hook 强制启动

为确保 go 在每次对话中自动启动，在 `~/.claude/settings.json` 中配置 UserPromptSubmit hook：

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

> **为什么推荐 hook？** Claude Code 默认不强制任何 skill 启动。hook 确保 go 在每轮对话的第一步就被调用，防止模型绕过 skill 系统直接手写代码。DeepSeek 等非 Claude 后端尤其需要——它们不会像 Claude 模型那样主动识别 skill 触发词。

## 4. Hook 配置后效果

配置 hook 后，每轮对话自动注入 go-mandate 块：

```
[go-mandate] 收到用户请求 → 第一个动作：调用 Skill(skill="go", args="...")
```

模型被强制提醒：**先经过 go，再由 go 决定调用哪个 skill。** 不再跳过 skill 手写代码。

## 5. 日常使用

```
你: "go 开工，帮我分析这批单细胞数据"
    → go 精炼意图 → 匹配 scrna_seq 能力 → 找到你的单细胞 skill → 编排 → 执行

你: "go 重排"
    → 重新扫描所有 skill → 重新匹配 → 你重新确认优先级

你: "go 状态"
    → 查看当前能力标签 → skill 映射表
```

## 6. 安装新 skill 后

安装新 skill 后，下次说 "go 开工" 时 go 自动检测：

```
⚠ go 检测到新 skill: celltypist
  能力标签: scrna_seq (单细胞分析)
  当前配置: scrna_seq → scrnaseq-pipeline
  建议: 将 celltypist 添加为备选 [y/n]
```

## 7. 当工作流效果不理想时

选项 A: 说 **"go 重排"** 重新全量配置

选项 B: 提供反馈 **"XX skill 在画图时效果不好"** — go 记录到 feedback_log，下次优先尝试备选

## 8. 常见问题

**Q: go 扫描不到某个 skill？**
A: 该 skill 的 description 关键词未命中能力标签的 keywords。你可以：① 说 "go 重排" 重试；② 提 issue 让 go 维护者扩增 keywords。

**Q: 可以不用 hook 吗？**
A: 可以，但需要每次对话开始时手动说 "go 开工"。DeepSeek 后端尤其建议用 hook。

**Q: go 会覆盖我已有的配置吗？**
A: 不会。go 只在首次初始化或你说 "go 重排" 时修改 go-config.json。日常使用只读不写。
