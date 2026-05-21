---
name: git-readonly
description: Claude Code Skill — 禁止所有會修改 git 狀態的操作，只允許閱讀與查詢
---

# git-readonly

> Claude Code Skill — 禁止所有會修改 git 狀態的操作，只允許閱讀與查詢

---

## 這個 Skill 做什麼？

啟用後 Claude Code 只能執行 git 唯讀指令，防止意外執行 commit、push 等修改 repository 狀態的操作。適合用於程式碼審查、歷史查詢等只需要閱讀的情境。

---

## 安裝

```bash
claude skill install git-readonly-skill.skill
```

---

## 禁止的操作

### 提交類
```bash
git commit
git commit --amend
git commit --no-edit
```

### 推送類
```bash
git push
git push --force
git push --force-with-lease
git push origin <branch>
```

### 分支修改類
```bash
git merge
git rebase
git cherry-pick
git branch -d / -D
git branch -m
```

### 重置類
```bash
git reset
git reset --hard / --soft
git revert
git restore
git checkout -- <file>
```

### 遠端修改類
```bash
git remote add / remove / set-url
git push --tags
git push --delete
git fetch --prune
```

### 暫存類
```bash
git stash
git stash pop / drop / clear
```

### 清理類
```bash
git clean
git gc
git clone
git init
```

---

## 允許的操作

### 查看狀態
```bash
git status
git status --short
```

### 查看歷史
```bash
git log
git log --oneline
git log --graph --all
git show <commit>
git show <commit>:<file>
```

### 查看差異
```bash
git diff
git diff <branch>
git diff <commit>..<commit>
git diff --staged
git diff --name-only
```

### 查看分支
```bash
git branch
git branch -a
git branch -r
git branch -v
```

### 查看遠端
```bash
git remote -v
git remote show <name>
```

### 搜尋與追蹤
```bash
git grep <pattern>
git blame <file>
git tag -l
git ls-remote
git config --list
```

---

## 遇到禁止操作時的回應

Claude Code 會明確說明禁止原因，並提供對應的唯讀替代指令：

```
⛔ git commit 在唯讀模式下被禁止。

目前只允許閱讀與查詢操作。
若你想查看目前的變更內容，可以使用：
  git diff
  git status
```

---

## Edge Cases

| 情況 | 處理方式 |
|------|---------|
| `git fetch`（不含 `--prune`）| ✅ 允許（只取得遠端資訊）|
| `git checkout <branch>` | ⛔ 禁止（會修改工作目錄）|
| `git switch` | ⛔ 禁止（同上）|
| Shell script 含禁止指令 | ⛔ 禁止撰寫，並說明原因 |
