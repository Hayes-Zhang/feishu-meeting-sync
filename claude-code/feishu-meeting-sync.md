---
description: 同步飞书会议纪要到本地
allowed-tools: Bash, Read, Glob
---

根据用户参数执行对应的同步操作：

- 无参数 → `feishu-sync --today`
- `--today` → `feishu-sync --today`
- `--recent` → `feishu-sync --recent`
- `--search <关键词>` → `feishu-sync --search "<关键词>"`
- `--list` → `feishu-sync --list`
- `--force` → 追加到任何命令后
- 其他参数 → 视为飞书文档 URL 或 doc_id

用 Bash 工具运行 `feishu-sync` 加对应参数。完成后告诉用户同步了哪些会议。
