# feishu-meeting-sync

飞书会议纪要 → 本地 Markdown，一条命令搞定。

Sync Feishu (飞书) meeting minutes to local Markdown files — with AI summary boards, images, and transcripts.

## 它能做什么

配合 Claude Code 使用，你可以直接用自然语言操作：

> "帮我拉一下今天的会议纪要"
>
> "同步一下最近跟马斯克聊的会议"
>
> "把这个会议拉下来 https://xxx.feishu.cn/docx/ABC123"

自动拉取的内容：
- **智能纪要** — Markdown 格式，AI 总结画板嵌在「总结」下方，其他图片放附件
- **文字记录（逐字稿）** — 自动从智能纪要的「相关链接」中解析并拉取
- **妙记录音转录** — 带说话人 + 时间戳
- **每次会议一个文件夹** — `日期 主题 [开始时间]`，同一天多场会议自动用时间区分

```
feishu-meetings/
├── 2026-03-20 产品优化与推广研讨/
│   ├── 2026-03-20 产品优化与推广研讨 智能纪要.md
│   ├── 2026-03-20 产品优化与推广研讨 文字记录.md
│   └── images/
│       ├── board_xxx.png    ← AI 总结画板
│       └── img_xxx.png      ← 文档图片
```

## 快速开始

### 1. 创建飞书应用

1. 打开 [飞书开放平台](https://open.feishu.cn/app) → 创建企业自建应用
2. **权限管理** → 搜索并开通以下权限：
   - `docx:document:readonly` — 查看升级版文档
   - `docs:doc:readonly` — 查看文档
   - `docs:document.content:read` — 查看文档内容
   - `drive:drive:readonly` — 查看云空间文件
   - `wiki:wiki:readonly` — 查看知识库
   - `space:document:retrieve` — 获取文档列表
   - `minutes:minutes:readonly` — 查看妙记
   - `minutes:minutes.transcript:export` — 导出妙记转写内容
   - `minutes:minutes.media:export` — 下载妙记音视频
   - `board:whiteboard:node:read` — 查看画板
3. **安全设置** → 重定向 URL → 添加 `http://localhost:9999/callback`
4. **版本管理与发布** → 创建版本 → 发布

### 2. 安装

```bash
git clone https://github.com/Hayes-Zhang/feishu-meeting-sync.git
cd feishu-meeting-sync
bash setup.sh
```

### 3. 配置环境变量

```bash
# 添加到 ~/.zshrc 或 ~/.bashrc
export PATH="$HOME/bin:$PATH"
export LARK_CONFIG_DIR="$HOME/.lark"
export LARK_APP_ID="你的 App ID"
export LARK_APP_SECRET="你的 App Secret"
```

### 4. 首次登录

```bash
source ~/.zshrc
lark auth login --scopes minutes,documents
```

浏览器会打开飞书授权页面，点击授权即可。

### 5. 开始使用

```bash
# 同步今天的会议
feishu-sync --today

# 同步指定会议（给智能纪要链接）
feishu-sync https://xxx.feishu.cn/docx/ABC123

# 同步妙记录音（自动导出带说话人+时间戳的转录）
feishu-sync https://xxx.feishu.cn/minutes/obcnXXX

# 搜索并同步
feishu-sync --search "产品讨论"

# 查看已同步的会议
feishu-sync --list

# 强制重新同步
feishu-sync --force --today
```

## 与 Claude Code 集成

复制 `claude-code/` 目录下的文件到你的 Claude Code skills/commands 目录：

```bash
# Skill（自动触发：说"拉会议纪要"即可）
cp claude-code/SKILL.md ~/.claude/skills/feishu-meeting/SKILL.md

# 斜杠命令
cp claude-code/feishu-meeting-sync.md ~/.claude/commands/feishu-meeting-sync.md
```

之后在 Claude Code 里可以：
- 说「拉一下今天的会议纪要」→ 自动同步
- 输入 `/feishu-meeting-sync` → 同步今天的会议
- 发飞书链接 → 自动识别并同步

## 特性

| 特性 | 说明 |
|---|---|
| 自动关联 | 给智能纪要链接，自动发现并拉取文字记录 |
| 妙记录音 | 支持 `/minutes/` 链接，导出带说话人+时间戳的转录 |
| 增量同步 | 已同步的会议自动跳过，不会重复拉取 |
| AI 画板 | 飞书妙记的 AI 总结画板自动下载为图片 |
| 同名区分 | 同一天多场同名会议用开始时间后缀区分 |
| token 刷新 | token 过期时自动弹浏览器重新授权 |

## 环境变量

| 变量 | 默认值 | 说明 |
|---|---|---|
| `FEISHU_SYNC_DIR` | `~/feishu-meetings` | 会议文件输出目录 |
| `LARK_BIN` | `~/bin/lark` | lark CLI 路径 |
| `LARK_CONFIG_DIR` | `~/.lark` | 配置和 token 目录 |
| `LARK_APP_ID` | - | 飞书应用 App ID（必需） |
| `LARK_APP_SECRET` | - | 飞书应用 App Secret（必需） |

## 工作原理

```
飞书智能纪要 (docx)
    │
    ├─ 文档 API ──→ Markdown 文本
    ├─ 块 API ────→ 发现画板 (block_type=43) 和图片 (block_type=27)
    ├─ 画板 API ──→ 下载 AI 总结画板为 PNG
    ├─ 图片 API ──→ 下载文档内嵌图片
    └─ 解析「相关链接」──→ 发现文字记录 doc_id ──→ 递归拉取
```

底层依赖 [lark-cli](https://github.com/yjwong/lark-cli)（安装时自动适配飞书中国版域名）。

## 已知限制

- 飞书搜索 API 只返回自己空间的文档，合作伙伴创建的需要给链接
- token 刷新需要浏览器交互（飞书个人版不支持静默刷新）
- 目前仅支持 macOS 和 Linux

## 背景

这个工具解决的问题：飞书开完会后，AI 生成的会议纪要和逐字稿锁在飞书里，没法直接给 LLM 当上下文用。手动下载 Word 文件再喂给 AI 太麻烦了。

现在一条命令就能把会议内容变成本地 Markdown，直接作为 Claude Code / ChatGPT / 任何 AI 工具的上下文。

## License

MIT

## Author

**Hayes Zhang** (张无常) — 前字节跳动飞书/AnyGen AI 产品经理，公众号「张无常」
