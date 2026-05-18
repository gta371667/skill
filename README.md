# Flutter & Dart Claude Code Skills

專為 Flutter / Dart 專案設計的 Claude Code Skill 集合，自動化常見的程式碼生成任務。

---

## Skills 列表

| Skill | 功能 |
|-------|------|
| [flutter-bloc-skill](#flutter-bloc-skill) | 自動產生 BLoC 三檔案（bloc / event / state） |
| [flutter-freezed-response](#flutter-freezed-response) | 從 API Response JSON 產生 Freezed model |
| [dart-comment](#dart-comment) | 統一 Dart/Flutter 中文註解規範 |

---

## 安裝方式

### 方式一：單獨安裝 `.skill` 檔案

下載對應的 `.skill` 檔案後，在 Claude Code 執行：

```bash
claude skill install flutter-skill/flutter-bloc-skill/flutter-bloc.skill
claude skill install flutter-skill/flutter-freezed-response/flutter-freezed-response.skill
claude skill install flutter-skill/dart-comment/dart-comment.skill
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

`v1.0.3`
