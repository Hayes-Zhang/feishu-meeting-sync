---
name: feishu-meeting
description: 同步飞书会议纪要到本地。支持按链接、日期、关键词搜索拉取。触发词：拉会议纪要、同步会议、今天的会议、飞书纪要、feishu meeting。
user_invocable: true
---

# 飞书会议纪要同步

## 用户场景 → 执行方式

### 用户给了链接
```bash
feishu-sync <URL或doc_id>
```

### "拉一下今天的会议纪要"
```bash
feishu-sync --today
```

### "拉一下最近跟xx的会议纪要" / "同步最近的会议"
```bash
feishu-sync --search "智能纪要 关键词"
```

### "看看同步过哪些会议"
```bash
feishu-sync --list
```

### 强制重新同步
```bash
feishu-sync --force <URL或doc_id>
feishu-sync --force --today
```

## 特性

- 自动关联：给智能纪要链接，自动拉取对应的文字记录
- 增量同步：已同步的会议自动跳过
- 同名会议区分：同一天多场会议用开始时间后缀区分
- 画板下载：AI 总结画板插在「总结」下方
- token 自动刷新：过期时自动重新登录

## 完成后

告诉用户同步了哪些会议、文件保存在哪里。如果用户需要查看某个会议内容，直接用 Read 工具读取对应的 md 文件。
