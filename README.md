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
| `flutter-image-gen-skill` | 自動掃描 assets/images/ 產生圖片路徑管理檔案 |
| `git-readonly-skill` | 禁止所有 git 寫入操作，只允許閱讀與查詢 |

---

## 安裝方式

### 方式一：單獨安裝 `.skill` 檔案

下載對應的 `.skill` 檔案後，在 Claude Code 執行：

```bash
claude skill install flutter-skill/flutter-bloc-skill/flutter-bloc-skill.skill
claude skill install flutter-skill/flutter-response-model/flutter-response-model.skill
claude skill install flutter-skill/dart-comment/dart-comment-skill.skill
claude skill install flutter-skill/dart-style-guide/dart-style-guide.skill
claude skill install flutter-skill/flutter-project-knowledge/flutter-project-knowledge.skill
claude skill install flutter-skill/flutter-image-gen/flutter-image-gen.skill
claude skill install flutter-skill/git-readonly-skill/git-readonly-skill.skill
```

### 方式二：從 npm 安裝

```bash
npx gta371667-skills
```

或全域安裝後使用：

```bash
npm install -g gta371667-skills
```

---

## 版本

`v1.0.5`
