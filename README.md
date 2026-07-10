# Flutter & Dart Claude Code Skills

專為 Flutter / Dart 專案設計的 Claude Code Skill 集合，自動化常見的程式碼生成任務。

---

## Skills 列表

| Skill | 功能 |
|-------|------|
| `flutter-bloc-skill` | 自動產生 BLoC 三檔案（bloc / event / state） |
| `flutter-response-model` | 從 API Response JSON 產生 Equatable model |
| `dart-comment` | 統一 Dart/Flutter 中文註解規範 |
| `dart-style-guide` | Dart/Flutter 程式碼風格規範（命名、排列、import、格式化） |
| `flutter-project-knowledge` | Flutter 專案通用架構知識庫 |
| `flutter-image-gen` | 自動掃描 assets/images/ 產生圖片路徑管理檔案 |
| `git-readonly-skill` | 禁止所有 git 寫入操作，只允許閱讀與查詢 |

---

## 安裝方式

Claude Code 從 `~/.claude/skills/` 載入 skill，安裝就是把 skill 目錄複製過去。

### 方式一：從 npm

```bash
npm pack gta371667-skills
tar xzf gta371667-skills-*.tgz
mkdir -p ~/.claude/skills
cp -r package/flutter-skill/* ~/.claude/skills/
rm -rf package gta371667-skills-*.tgz
```

### 方式二：從原始碼

```bash
git clone <repo-url> /tmp/skill
mkdir -p ~/.claude/skills
cp -r /tmp/skill/flutter-skill/* ~/.claude/skills/
```

### 只在單一專案啟用

把 skill 目錄複製到專案的 `.claude/skills/` 而非 `~/.claude/skills/`：

```bash
mkdir -p .claude/skills
cp -r /path/to/flutter-skill/flutter-bloc-skill .claude/skills/
```

### 安裝後

重開 Claude Code session 即可載入。skill 會依 `SKILL.md` 的 `description` 自動觸發，也可以直接說「幫我建立 XXX 的 bloc」。

---

## 開發說明

每個 skill 目錄下的 `.skill` 檔是 zip 打包檔，**安裝流程不會用到**，僅供保留原始打包結果。實際被 Claude Code 讀取的是 `SKILL.md` 以及同層的 `references/`、`assets/`。

`SKILL.md` 的 frontmatter `name` 必須與所在目錄名一致。

---

## 版本

`v1.0.6`
